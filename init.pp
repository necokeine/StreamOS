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

unit
	init;

interface

uses
	stypes;

var
	initName: String;
	initParams: TDynamicStringList;

procedure InitKernelVariables;

implementation

uses
	kernel,
	syscalls,
	modules,
	sysutils,
	tools,
	fs,
	debug,
	managers,
	lock,
	keyboard;

{$i config.inc}

var
	lineParam1, lineParam2: TDynamicStringList;

procedure InitKernelVariables;
var
	i, k: Longint;
begin
	(*
		here all kernel variables are initialized. If you add some
		global variable, you *MUST* initialize it here. For more
		difficult cases (like some managers) you should create another
		initializing procedure, but in init.pp and make a call of it
		from streamos.pp file *AFTER* calling this procedure
	*)

	Randomize;
	SetLength(kernel.process, 1);

	InitKeyboard;

	(*here we must init KERNEL virtual process*)
	with kernel.process[0] do
		begin
			processName := 'kernel';
			processUser := 0;
			processStartTime := now;
			processState := tps_running;
			processAccessKey := tools.ToolsGenerateAccessKey;
			processDisplay := 0;
			processSignal := 0;
			processSignalSender := 0;
			processParentDisplay := 0;
			processParentPid := 0;
			processMainThreadId := 0;
			processCurrentDirectory := '/';
			processTimerIdProcessing := 0;
			SetLength(processChildren, 1);
			SetLength(processExports.te_pointers, 1);
			SetLength(processExports.te_names, 1);
			SetLength(processTimers, 1);
			processKey := #0;
			InitLock(processMessageLock);
			InitLock(processChildrenLock);
			InitLock(processTimerIdProcessingLock);
			pointer(processOnMessageHandlerProcedure) := @kernel.KernelOnMessageHandler;
		end;

	(*sets system calls*)
	syscalls.SyscallsSetSystemCalls;

	(*sets default values for kernel variables*)
	kernel.kernelInternalTimerInterval := 5;
	kernel.kernelRoot := 'C';
	kernel.kernelHostname := '[not set]';
	initName := '/bin/init';
	setLength(initParams, 2);
	initParams[1] := '/etc/inittab';
	debug.debugToFile := true;
	(*processes kernel command line*)
	if ParamCount > 0 then
		for i:=1 to ParamCount do
			begin
				(*
					splitting into variables and values
					lineParam1[1] - the name of parameter
					lineParam2[] - options
				*)
				SetLength(lineParam1, 1);
				lineParam1[0] := '';
				SetLength(lineParam2, 1);
				lineParam2[0] := '';
				lineParam1 := tools.ToolsSplitLine(ParamStr(i), '=');
				if Length(lineParam1) > 1 then
					lineParam2 := tools.ToolsSplitLine(lineParam1[2], ',');
				(*processing each command*)
				if lineParam1[1] = 'init' then
					begin
						(*assigning init name*)
						initName := lineParam2[1];
						(*transferring init parameters*)
						for k := 1 to Length(lineParam2) - 1 do
						initParams[k] := lineParam2[k + 1];
					end
						else
				if lineParam1[1] = 'timer' then
					begin
						(*assigning internal timer interval*)
						kernel.kernelInternalTimerInterval := round(1000 / StrToInt(lineParam2[1]));
					end
						else
				if lineParam1[1] = 'debug' then
					begin
						(*direct debug output to file or screen*)
						{$ifdef config_debug}
						if lineParam2[1] = 'file' then
							debug.debugToFile := true
						else
							debug.debugToFile := false;
						{$endif}
					end;
			end;

	(*sets root directory*)
	fs.FsAddToFsTab(kernel.kernelRoot + ':\', '/', 'fat', 'defaults');
	(*inits kernel locks*)
	InitLock(managers.managersLockMessages);
	InitLock(managers.managersLockTimers);
	InitLock(managers.managersLockKeys);
	InitLock(managers.managersLockExternal);
	InitLock(managers.managersLockSingleExternal);
	InitLock(kernel.kernelProcessQueueLock);
	InitLock(kernel.kernelForkLock);
	{$ifdef config_debug}
		InitLock(debug.debugLock);
	{$endif}
	(*loads kernel modules*)
	modules.LoadKernelModules;
end;

begin
end.

