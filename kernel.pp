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
	kernel;

(*
	this is a core of StreamOS kernel. You may find here process descriptors,
	process management functions
*)

interface

uses
	stypes,
	dynlibs;

{$i config.inc}

type
	TProcess = record																			(*process container type	*)
		processName: String;																	(*name							*)
		processUser: Longint;																(*owner							*)
		processParentPid: Longint;															(*parent							*)
		processChildren: TProcessChildren;												(*children						*)
		processChildrenLock: TLockContainer;											(*children array lock		*)
		processStartTime: Extended;														(*start time					*)
		processParameters: TDynamicStringList;											(*parameters					*)
		processState: TProcessState;														(*state							*)
		processLibrary: TLibHandle;														(*DLL pointer					*)
		processMainThreadProcedure: TProcessMainProcedure;							(*main procedure				*)
		processOnKeyHandlerProcedure: TProcessOnKeyHandlerProcedure;			(*keypress handler			*)
		processKey: Char;																		(*pressed key					*)
		processKeyLock: TLockContainer;													(*key handler lock			*)
		processOnMessageHandlerProcedure: TProcessOnMessageHandlerProcedure;	(*message handler				*)
		processMessage:TMessage;															(*message						*)
		processMessageLock: TLockContainer;												(*lock message					*)
		processOnSignalHandlerProcedure: TProcessOnSignalHandlerProcedure;	(*signal handler				*)
		processSignal: Longint;																(*signal number				*)
		processSignalSender: Longint;														(*sender's PID					*)
		processMainThreadId: TThreadId;													(*main thread ID				*)
		processExports: TExports;															(*exported process			*)
		processAccessKey: TAccessKey;														(*system calls access key	*)
		processDisplay: Longint;															(*display						*)
		processParentDisplay: Longint;													(*parent's display			*)
		processCurrentDirectory: String;													(*current directory			*)
		processLock: TLockContainer;														(*process struct lock		*)
		processTimers: array of TTimer;													(*process timers				*)
		processTimerIdProcessing: Longint;												(*ID of starting timer		*)
		processTimerIdProcessingLock: TLockContainer;								(*timer ID lock				*)
	end;

var
	process: array of TProcess;										(*processes table					*)
	kernelInternalTimerInterval: Longint;							(*interval of internal timer	*)
	kernelRoot: String;													(*root drive						*)
	kernelHostname: String;												(*hostname							*)
	kernelProcessQueueLock, kernelForkLock: TLockContainer;	(*process queue lock				*)

function  KernelProcessCreate(fileName: String; parameters: TDynamicStringList; parentPid: Longint; user: Longint): Longint;
function  KernelProcessDestroy(pid: Longint): Boolean;
procedure KernelOnMessageHandler(message: TMessage);

implementation

uses
	syscalls,
	sysutils,
	errorman,
	tools,
	managers,
	modules,
	fs,
	debug,
	lock;

(*===creates new process===*)
function KernelProcessCreate(fileName: String; parameters: TDynamicStringList; parentPid: Longint; user: Longint): Longint;
var
	pid, i: Longint;
	whereToSearch, toLoad: String;
	extend: Boolean;
begin
	(*locks create/destroy functions*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, entering fork section');
	{$endif}
	EnterLock(kernelForkLock);
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, in fork section');
	{$endif}

	(*looks for free pid*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, looking for free PID');
	{$endif}
	pid := 0;
	EnterLock(kernelProcessQueueLock);
	repeat
		inc(pid);
	until (pid > Length(process) - 1) or
		(process[pid].processState = tps_none);
	(*if not found free cell, make a new one*)
	if pid > (Length(process) - 1) then
		begin
			SetLength(process, Length(process) + 1);
			extend := true;
		end
	else
		extend := false;
	LeaveLock(kernelProcessQueueLock);

	try
		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, initializing variables for [pid=' + inttostr(pid) + ', name=' + filename + ']');
		{$endif}

		(*assigns main process variables*)
		with process[pid] do
			begin
				processState := tps_creating;
				processName := fileName;
				processParentPid := parentPid;
				processAccessKey := tools.ToolsGenerateAccessKey;
				processParameters := parameters;
				processDisplay := -1;
				processParentDisplay := process[parentpid].processDisplay;
				processCurrentDirectory := process[parentpid].processCurrentDirectory;
				processUser := user;
				processKey := #0;
				processTimerIdProcessing := 0;
				InitLock(processMessageLock);
				InitLock(processChildrenLock);
				InitLock(processLock);
				InitLock(processKeyLock);
				InitLock(processTimerIdProcessingLock);
				processSignal := 0;
				processSignalSender := 0;
				SetLength(processExports.te_pointers, 1);
				SetLength(processExports.te_names, 1);
				SetLength(processChildren, 1);
				SetLength(processTimers, 1);
			end;

		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, loading library [pid=' + inttostr(pid) + ', name=' + filename + ']');
		{$endif}
		(*loads dll, resolvs filename*)
		whereToSearch := GetEnvironmentVariable('PATH');
		if ExtractFileName(fileName) = fileName then
			toLoad := FileSearch(fs.StreamFSToDOS(fileName), whereToSearch)
		else
			toLoad := fs.StreamFSToDOS(fileName);

		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, copying DLL to RAM-disk [pid=' + IntToStr(pid) + ', name=' + fileName + ']');
		{$endif}
		(*
			copies dll to RAM-disk. It's used to avoid bug with copies of one
			program. If we need to run several copies of one program, we copy
			dll several times to RAM-disk under different names (pids)
		*)
		if (toload = '') or
			(not fs.FsCopyFile(toload, 'Z:\' + IntToStr(pid))) then
			raise(EAccessViolation.Create('file copying error'));

		(*loads dll from RAM-disk*)
		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, loading DLL from RAM-disk [pid=' + IntToStr(pid) + ', name=' + fileName + ']');
		{$endif}
		process[pid].processLibrary := loadlibrary('Z:\' + IntToStr(pid) + '.');
		if process[pid].processLibrary = 0 then
			raise(EAccessViolation.Create('library loading error'));

		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, loading procedures [pid=' + IntToStr(pid) + ', name=' + fileName + ']');
		{$endif}

		(*sets procedures*)
		pointer(process[pid].processMainThreadProcedure)       := GetProcedureAddress(process[pid].processLibrary, 'lib_main');
		pointer(process[pid].processOnKeyHandlerProcedure)     := GetProcedureAddress(process[pid].processLibrary, 'lib_key');
		pointer(process[pid].processOnMessageHandlerProcedure) := GetProcedureAddress(process[pid].processLibrary, 'lib_msg');
		pointer(process[pid].processOnSignalHandlerProcedure)  := GetProcedureAddress(process[pid].processLibrary, 'lib_signal');

		(*adds new child to parent*)
		EnterLock(process[parentpid].processChildrenLock);
		i:=0;
		repeat
			inc(i);
		until (i > Length(process[parentpid].processChildren) - 1) or
			(process[parentpid].processChildren[i] = 0);
		if i > Length(process[parentpid].processChildren) - 1 then
			SetLength(process[parentpid].processChildren, Length(process[parentpid].processChildren) + 1);
		process[parentpid].processChildren[i] := pid;
		LeaveLock(process[parentpid].processChildrenLock);

		(*removes temporary file from Z:\*)
		DeleteFile('Z:\' + IntToStr(pid));

		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, starting a new thread [pid=' + IntToStr(pid) + ', name=' + fileName + ']');
		{$endif}

		(*starts new thread*)
		process[pid].processState := tps_running;
		{$ifdef config_debug}
			{$ifdef collect_lock_statistic}
				debug.DebugReportEvent('Locks [i:' + IntToStr(nr_init) + ', e:' + IntToStr(nr_enter) + ', l:' + IntToStr(nr_leave) + ', d:' + IntToStr(nr_done) + ', w:' + IntToStr(nr_wait) + ', a:' + IntToStr(nr_is) + ']');
			{$endif}
		{$endif}
		EnterLock(managersLockExternal);
		BeginThread(@managers.ManagersExecuteExternal, pointer(pid));
		WaitLock(managersLockExternal);
		process[pid].processStartTime := now;
		{$ifdef config_debug}
			debug.DebugReportEvent('Kernel, thread started [pid=' + IntToStr(pid) + ', name=' + fileName + ']');
		{$endif}

		KernelProcessCreate := pid;
	except
		on e: exception do
			begin
				(*clean and report about error*)
				if extend then
					begin
						EnterLock(kernelProcessQueueLock);
						SetLength(process, Length(process) - 1);
						LeaveLock(kernelProcessQueueLock);
					end;
				errorman.ErrormanRaiseKernelError(0, e.message);
				KernelProcessCreate := -1;
			end;
	end;

	(*unlocks the function*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, leaving fork section');
	{$endif}
	LeaveLock(kernelForkLock);
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, out of fork section');
	{$endif}
end;

(*===destroys given process===*)
function KernelProcessDestroy(pid: Longint): Boolean;
var
	i:longint;
begin
	(*locks create/destroy functions*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, entering fork section]');
	{$endif}
	EnterLock(kernelForkLock);
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, in fork section]');
	{$endif}

	if (pid < Length(process)) and
		(pid > 0) and
		(not (process[pid].processState = tps_none)) then
		begin
			try
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, destroying child processes [pid=' + IntToStr(pid) + ']');
				{$endif}
				(*marking as being destroyed*)
				process[pid].processState := tps_destroying;
				(*destroying timers immediately*)
				for i:= 1 to Length(process[pid].processTimers) - 1 do
					if process[pid].processTimers[i].timerOwner = pid then
						begin
							with process[pid].processTimers[i] do
								begin
									timerProcedure := nil;
									timerInterval := 0;
									timerEnabled := false;
									timerLastExecuted := 0;
									timerOwner := -1;
									timerThreadId := 0;
								end;
							if i = Length(process[pid].processTimers) - 1 then
								SetLength(process[pid].processTimers, Length(process[pid].processTimers) - 1);
						end;
				(*it probably causes deadlock, haven't tested it yet*)
				for i := 1 to Length(process[pid].processChildren) - 1 do
					KernelProcessDestroy(process[pid].processChildren[i]);
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, unloading library [pid=' + inttostr(pid) + ']');
				{$endif}
				if not UnloadLibrary(process[pid].processLibrary) then
					errorman.ErrormanRaiseKernelError(1, 'Library unloading error');

				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, cleaning variables [pid='+inttostr(pid)+']');
				{$endif}
				(*prevent bad-written application from leaking displays*)
				if not (process[pid].processDisplay = -1) then
					DisplayDestroyDisplay(process[pid].processDisplay);
				(*clean parent's children array*)
				EnterLock(process[process[pid].processParentPid].processChildrenLock);
				for i := 1 to Length(process[process[pid].processParentPid].processChildren) do
					if process[process[pid].processParentPid].processChildren[i] = pid then
						begin
							process[process[pid].processParentPid].processChildren[i] := 0;
							if i = Length(process[process[pid].processParentPid].processChildren) - 1 then
								SetLength(process[process[pid].processParentPid].processChildren, Length(process[process[pid].processParentPid].processChildren) - 1);
						end;
				LeaveLock(process[process[pid].processParentPid].processChildrenLock);

				(*clean variables*)
				with process[pid] do
					begin
						processState := tps_none;
						processName := '';
						processDisplay := -1;
						processParentDisplay := -1;
						processParentPid := 0;
						processCurrentDirectory := '';
						processUser := -1;
						processSignal := 0;
						processSignalSender := 0;
						SetLength(processExports.te_pointers, 0);
						SetLength(processExports.te_names, 0);
						SetLength(processChildren, 0);
						SetLength(processTimers, 0);
						processKey := #0;
						DoneLock(processMessageLock);
						DoneLock(processChildrenLock);
						DoneLock(processLock);
						DoneLock(processKeyLock);
						DoneLock(processTimerIdProcessingLock);
						processStartTime := 0;
						SetLength(processParameters, 0);
						processLibrary := 0;
						pointer(processMainThreadProcedure) := nil;
						pointer(processOnKeyHandlerProcedure) := nil;
						pointer(processOnMessageHandlerProcedure) := nil;
						pointer(processOnSignalHandlerProcedure) := nil;
						processMainThreadId := 0;
					end;

				(*clean process queue if needed*)
				EnterLock(kernelProcessQueueLock);
				if pid = Length(process) - 1 then
					SetLength(process, pid);
				LeaveLock(kernelProcessQueueLock);

				KernelProcessDestroy := true;
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, destroyed [pid=' + IntToStr(pid) + ']');
				{$endif}
			except
				on e: exception do
					begin
						errorman.ErrormanRaiseKernelError(1, e.message);
						KernelProcessDestroy := false;
					end;
			end;
		end
	else
		KernelProcessDestroy := false;

	(*unlocks the function*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, leaving fork section');
	{$endif}
	LeaveLock(kernelForkLock);
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, out of fork section');
	{$endif}
end;

(*===handles messages===*)
procedure KernelOnMessageHandler(message: TMessage);
begin
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, got a message from [pid=' + inttostr(message.messageSender) + ']');
	{$endif}
end;

begin
end.

