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
	login;

uses
	sharedmem,
	stypes,
	tools,
	imports,
	md5,
	sysutils,
	inifiles;

type
	TUser = record
		name, hash, shell: String;
		uid: Longint;
	end;

var
	quit: Boolean;
	command, uhash, ulogin, towait, ushell: String;
	mydisplay, uuid: Longint;
	users: array of TUser;

procedure dowork;
begin
	TextOutLn('');
	if towait = 'login' then
		begin
			ulogin := command;
			quit := true;
		end
			else
	if towait = 'password' then
		begin
			uhash := md5print(md5string(command));
			quit := true;
		end;
	command := '';
end;

procedure keyhandler(trancode: Char);
begin
	(*if ENTER*)
	if trancode = #13 then
		(*executes a command*)
		dowork
		else
	(*if BACKSPACE*)
	if trancode = #8 then
		begin
			if Length(command) > 0 then
				begin
					(*it deletes a symbol from buffer and screen*)
					SetLength(command, Length(command) - 1);
					if towait = 'login' then
						deletelastsymbol;
				end;
		end
	else
		begin
			(*if another key, just add it to buffer*)
			command += trancode;
			if towait = 'login' then
				textout(trancode);
		end;
end;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey); export;
var
	params: TDynamicStringList;
	f: TIniFile;
	si: TProcessInfo;
	shadowname: String;
	shell_pid, count, k: Longint;
	correct: Boolean;
begin
	(*init*)
	command := '';
	ulogin := '';
	uhash := '';
	towait := '';
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*loading the file with users and shadowed passwords into memory*)
	shadowname := '/etc/shadow';
	if GetParametersCount > 0 then
		begin
			mydisplay := StrToInt(GetParameter(1));
			RegisterDisplay(mydisplay);
			repeat
				SetLength(users, 1);
				f := TIniFile.Create(FsGetDosPath(shadowname));
				count := f.ReadInteger('common', 'count', 0);
				for k := 1 to count do
					begin
						SetLength(users, Length(users) + 1);
						users[Length(users) - 1].name := f.ReadString('user_' + IntToStr(k), 'login', '');
						users[Length(users) - 1].hash := f.ReadString('user_' + IntToStr(k), 'hash', '');
						users[Length(users) - 1].uid := f.ReadInteger('user_' + IntToStr(k), 'uid', 0);
						users[Length(users) - 1].shell := f.ReadString('user_' + IntToStr(k), 'shell', '/bin/sshell');
					end;
				f.Free;

				repeat
					correct := false;
					(*login*)
					quit := false;
					towait := 'login';
					TextOut(IntToStr(mydisplay) + ' login: ');
					(*waiting for login*)
					repeat
						Stay(GetKernelInfo.osInternalTimerInterval);
					until quit;

					(*password*)
					quit := false;
					towait := 'password';
					TextOut('password: ');
					(*waiting for password*)
					repeat
						Stay(getkernelinfo.osInternalTimerInterval);
					until quit;

					for k := 1 to Length(users) - 1 do
						begin
							if (users[k].name = ulogin) and
								(users[k].hash = uhash) then
								begin
									ushell := users[k].shell;
									uuid := users[k].uid;
									correct := true;
									break;
								end;
						end;
				until correct;
				(*after exiting starts shell*)
				SetLength(params, 1);
				params[0] := '';
				shell_pid := ProcessCreate(ushell, params, pid, uuid);
				si := KernelGetProcessInfo(shell_pid);
				WaitForThreadTerminate(si.pTID, 0);
			until false;
		end;
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

