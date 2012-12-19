// vim: ts=3:filetype=pascal

(* Copyright (C) 2004-2009 Oleksandr Natalenko aka post-factum

   This program is free software; you can redistribute it and/or modify
   it under the terms of the Universal Program License as published by
   Oleksandr Natalenko aka post-factum; see file COPYING for details.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   You should have received a copy of the Universal Program
   License along with this program; if not, write to
   pfactum@gmail.com *)

library
	init;

uses
	sharedmem,
	stypes,
	sysutils,
	tools,
	imports,
	inifiles,
	lock;

var
	s_exec: String;
	l_opts: TDynamicStringList;
	mypid: Longint;
	lock_init: TLockContainer;

function spawn_process(p: Pointer): Longint;
var
	spawn_pid: Longint;
	spawn_info: TProcessInfo;
	local_s_exec: String;
	local_l_opts: TDynamicStringList;
begin
	spawn_process := 0;
	local_s_exec := s_exec;
	local_l_opts := l_opts;
	LeaveLock(lock_init);
	repeat
		spawn_pid := ProcessCreate(local_s_exec, local_l_opts, mypid, 0); 
		if spawn_pid = -1 then
			begin
				TextOutLn('Init: failed to run "' + local_s_exec + '". Stop respawning.');
				break;
			end
		else
			begin
				spawn_info := KernelGetProcessInfo(spawn_pid);
				WaitForThreadTerminate(spawn_info.pTID, 0);
			end;
	until false;
end;


procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey); export;
var
    iprm, k, count: Longint;
    f: TIniFile;
    s_opts: String;
	 s_respawn: Boolean;
begin
	InitLock(lock_init);
	mypid := pid;
	(*getting system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	SetProcessName('init');
	(*registering at zero display*)
	RegisterDisplay(0);
	TextOutLn('Starting init...');
	(*starting to parse init script*)
	iprm := GetParametersCount;
	if iprm > 0 then
		begin
			f := TIniFile.Create(FsGetDOSPath(GetParameter(1)));
			count := f.ReadInteger('common', 'count', 0);
			for k := 1 to count do
				begin
					s_exec := f.ReadString('task_' + IntToStr(k), 'exec', '');
					s_opts := f.ReadString('task_' + IntToStr(k), 'opts', '');
					s_respawn := f.ReadBool('task_' + IntToStr(k), 'respawn', false);
					l_opts := tools.ToolsSplitLine(s_opts, #32);
					if s_respawn then
						begin
							EnterLock(lock_init);
							BeginThread(@spawn_process, nil);
							WaitLock(lock_init);
						end
					else
						begin
							if ProcessCreate(s_exec, l_opts, pid, 0) = -1 then
								TextOutLn('Init: failed to run "' + s_exec + '"');
						end;
				end;
			f.Free;
		end;
	repeat
		Stay(10000);
	until false;
end;

procedure keyhandler(trancode: Char);
begin
end;

procedure messagehandler(message: TMessage);
begin
end;

procedure signalhandler(signal, sender: Longint);
begin
end;

exports

main name 'lib_main',
keyhandler name 'lib_key',
messagehandler name 'lib_msg',
signalhandler name 'lib_signal';

begin
end.

