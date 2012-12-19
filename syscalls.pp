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
	syscalls;

interface

uses
	stypes,
	sysutils;

var
	systemCallsTable: TSystemCalls;

procedure SyscallsSetSystemCalls;

function  SyscallsProcessCreate               (filename: String; parameters: TDynamicStringList; parentPid, user: Longint; accessKey: TAccessKey): Longint;
function  SyscallsGetTimerInfo                (pid, index: Longint): TTimerInfo;
function  SyscallsGetParametersCount          (pid: Longint): Longint;
function  SyscallsGetParameter                (pid, id: Longint): String;
function  SyscallsGetProcessInfo              (pid: Longint): TProcessInfo;
function  SyscallsSetProcessName              (pid: Longint; name: String; accessKey: TAccessKey): Boolean;
function  SyscallsFindProcess                 (name: String): Longint;
function  SyscallsGetProcessPriority          (pid: Longint): Longint;
function  SyscallsSetProcessPriority          (pid, priority: Longint): Boolean;
function  SyscallsRegisterExports             (pid: Longint; p: TExports; accessKey: TAccessKey): Boolean;
function  SyscallsFindExport                  (pid: Longint; name: String): Longint;
function  SyscallsCallExport                  (pid, id: Longint; args: TPointers): TPointers;
function  SyscallsGetKernelInfo               (a_null: Pointer): TKernelInfo;
function  SyscallsSetInternalTimerInterval    (pid, interval: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsSendSignal                  (pid, rpid: Longint; signal: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsSendMessage                 (pid, rpid: Longint; message: Pointer; messageType: TMessageType; accessKey: TAccessKey): Boolean;
function  SyscallsRegisterDisplay             (pid, id: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsUnRegisterDisplay           (pid: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsAssignDisplayBuffer         (pid: Longint; buffer: TDisplayLines; accessKey: TAccessKey): Boolean;
function  SyscallsTextOut                     (pid: Longint; text: String; accessKey: TAccessKey): Boolean;
function  SyscallsTextOutLn                   (pid: Longint; text: String; accessKey: TAccessKey): Boolean;
function  SyscallsTextOutParse                (pid: Longint; text: String; accessKey: TAccessKey): Boolean;
function  SyscallsTextOutXy                   (pid, x, y: Longint; text: String; accessKey: TAccessKey): Boolean;
function  SyscallsDeleteLastLine              (pid: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsDeleteLastSymbol            (pid: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsClearDisplay                (pid: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsGetCurrentDisplay           (a_null: Pointer): Longint;
function  SyscallsGetEmptyDisplay             (a_null: Pointer): Longint;
function  SyscallsGetParentDisplay            (pid: Longint): Longint;
function  SyscallsGetCurrentDirectory         (pid: Longint): String;
function  SyscallsSetCurrentDirectory         (pid: Longint; dir: String; accessKey: TAccessKey): Boolean;
function  SyscallsSetHostname                 (pid: Longint; hostname: String; accessKey: TAccessKey): Boolean;
function  SyscallsFsGetDOSPath                (vfsFileName: String): String;
function  SyscallsFsFileExists                (filePath: String; fileType: TFileType): Boolean;
function  SyscallsFsAddFsTabRecord            (pid: Longint; fsTabRecord: TFsTabRecord; accessKey: TAccessKey): Boolean;
function  SyscallsAddApplicationTimer         (pid: Longint; timerProcedure: Pointer; timerInterval: Longint; timerEnabled: Boolean; accessKey: TAccessKey): Longint;
function  SyscallsRemoveApplicationTimer      (pid, id: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsResumeApplicationTimer      (pid, id: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsSuspendApplicationTimer     (pid, id: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsSetApplicationTimerInterval (pid, id, timerInterval: Longint; accessKey: TAccessKey): Boolean;
function  SyscallsInvokeApplicationTimer      (pid, id: Longint; accessKey: TAccessKey): Boolean;

implementation

uses
	kernel,
	tools,
	modules,
	managers,
	fs,
	lock;

{$i config.inc}

(*===sets system calls table===*)
procedure SyscallsSetSystemCalls;
begin
	SetLength(systemCallsTable, 42);

	systemCallsTable[1].tsc_pointer := @SyscallsProcessCreate;
	systemCallsTable[1].tsc_name := 'processcreate';

	systemCallsTable[2].tsc_pointer := @SyscallsGetTimerInfo;
	systemCallsTable[2].tsc_name := 'gettimerinfo';

	systemCallsTable[3].tsc_pointer := @SyscallsInvokeApplicationTimer;
	systemCallsTable[3].tsc_name := 'invokeapplicationtimer';

	systemCallsTable[4].tsc_pointer := @SyscallsGetParametersCount;
	systemCallsTable[4].tsc_name := 'getparameterscount';

	systemCallsTable[5].tsc_pointer := @SyscallsGetParameter;
	systemCallsTable[5].tsc_name := 'getparameter';

	systemCallsTable[6].tsc_pointer := @SyscallsGetProcessInfo;
	systemCallsTable[6].tsc_name := 'getprocessinfo';

	systemCallsTable[7].tsc_pointer := @SyscallsSetProcessName;
	systemCallsTable[7].tsc_name := 'setprocessname';

	systemCallsTable[8].tsc_pointer := @SyscallsFindProcess;
	systemCallsTable[8].tsc_name := 'findprocess';

	systemCallsTable[9].tsc_pointer := @SyscallsGetProcessPriority;
	systemCallsTable[9].tsc_name := 'getprocesspriority';

	systemCallsTable[10].tsc_pointer := @SyscallsSetProcessPriority;
	systemCallsTable[10].tsc_name := 'setprocesspriority';

	systemCallsTable[11].tsc_pointer := @SyscallsRegisterExports;
	systemCallsTable[11].tsc_name := 'registerexports';

	systemCallsTable[12].tsc_pointer := @SyscallsFindExport;
	systemCallsTable[12].tsc_name := 'findexport';

	systemCallsTable[13].tsc_pointer := @SyscallsCallExport;
	systemCallsTable[13].tsc_name := 'callexport';

	systemCallsTable[14].tsc_pointer := @SyscallsGetKernelInfo;
	systemCallsTable[14].tsc_name := 'getkernelinfo';

	systemCallsTable[15].tsc_pointer := @SyscallsSetInternalTimerInterval;
	systemCallsTable[15].tsc_name := 'setinternaltimerinterval';

	systemCallsTable[16].tsc_pointer := @SyscallsSendSignal;
	systemCallsTable[16].tsc_name := 'sendsignal';

	systemCallsTable[17].tsc_pointer := @SyscallsSendMessage;
	systemCallsTable[17].tsc_name := 'sendmessage';

	systemCallsTable[18].tsc_pointer := @SyscallsRegisterDisplay;
	systemCallsTable[18].tsc_name := 'registerdisplay';

	systemCallsTable[19].tsc_pointer := @SyscallsUnRegisterDisplay;
	systemCallsTable[19].tsc_name := 'unregisterdisplay';

	systemCallsTable[20].tsc_pointer := @SyscallsAssignDisplayBuffer;
	systemCallsTable[20].tsc_name := 'assigndisplaybuffer';

	systemCallsTable[21].tsc_pointer := @SyscallsTextOut;
	systemCallsTable[21].tsc_name := 'textout';

	systemCallsTable[22].tsc_pointer := @SyscallsTextOutLn;
	systemCallsTable[22].tsc_name := 'textoutln';

	systemCallsTable[23].tsc_pointer := @SyscallsTextOutParse;
	systemCallsTable[23].tsc_name := 'textoutparse';

	systemCallsTable[24].tsc_pointer := @SyscallsTextOutXy;
	systemCallsTable[24].tsc_name := 'textoutxy';

	systemCallsTable[25].tsc_pointer := @SyscallsDeleteLastLine;
	systemCallsTable[25].tsc_name := 'deletelastline';

	systemCallsTable[26].tsc_pointer := @SyscallsDeleteLastSymbol;
	systemCallsTable[26].tsc_name := 'deletelastsymbol';

	systemCallsTable[27].tsc_pointer := @SyscallsClearDisplay;
	systemCallsTable[27].tsc_name := 'cleardisplay';

	systemCallsTable[28].tsc_pointer := @SyscallsGetCurrentDisplay;
	systemCallsTable[28].tsc_name := 'getcurrentdisplay';

	systemCallsTable[29].tsc_pointer := @SyscallsGetEmptyDisplay;
	systemCallsTable[29].tsc_name := 'getemptydisplay';

	systemCallsTable[30].tsc_pointer := @SyscallsGetParentDisplay;
	systemCallsTable[30].tsc_name := 'getparentdisplay';

	systemCallsTable[31].tsc_pointer := @SyscallsGetCurrentDirectory;
	systemCallsTable[31].tsc_name := 'getcurrentdirectory';

	systemCallsTable[32].tsc_pointer := @SyscallsSetCurrentDirectory;
	systemCallsTable[32].tsc_name := 'setcurrentdirectory';

	systemCallsTable[33].tsc_pointer := @SyscallsSetHostname;
	systemCallsTable[33].tsc_name := 'sethostname';

	systemCallsTable[34].tsc_pointer := @SyscallsFsGetDOSPath;
	systemCallsTable[34].tsc_name := 'fsgetdospath';

	systemCallsTable[35].tsc_pointer := @SyscallsFsFileExists;
	systemCallsTable[35].tsc_name := 'fsfileexists';

	systemCallsTable[36].tsc_pointer := @SyscallsFsAddFsTabRecord;
	systemCallsTable[36].tsc_name := 'fsaddfstabrecord';

	systemCallsTable[37].tsc_pointer := @SyscallsAddApplicationTimer;
	systemCallsTable[37].tsc_name := 'addapplicationtimer';

	systemCallsTable[38].tsc_pointer := @SyscallsRemoveApplicationTimer;
	systemCallsTable[38].tsc_name := 'removeapplicationtimer';

	systemCallsTable[39].tsc_pointer := @SyscallsResumeApplicationTimer;
	systemCallsTable[39].tsc_name := 'resumeapplicationtimer';

	systemCallsTable[40].tsc_pointer := @SyscallsSuspendApplicationTimer;
	systemCallsTable[40].tsc_name := 'suspendapplicationtimer';

	systemCallsTable[41].tsc_pointer := @SyscallsSetApplicationTimerInterval;
	systemCallsTable[41].tsc_name := 'setapplicationtimerinterval';
end;

(*===creates new process===*)
function SyscallsProcessCreate(filename: String; parameters: TDynamicStringList; parentPid, user: Longint; accessKey: TAccessKey): Longint;
var
	procUser: Longint;
begin
	if (parentPid > -1) and
		(parentPid < Length(process)) and
		(not (filename = '')) and
		(user > -1 ) and
		(tools.ToolsCompareAccessKeys(process[parentPid].processAccessKey, accessKey)) then
		begin
			procUser := process[parentPid].processUser;
			if procUser = 0 then
				SyscallsProcessCreate := kernel.KernelProcessCreate(fileName, parameters, parentPid, user)
			else
				SyscallsProcessCreate := kernel.KernelProcessCreate(fileName, parameters, parentPid, procUser);
		end
	else
		begin
			SyscallsProcessCreate := -1;
		end;
end;

(*===returns timer info===*)
function SyscallsGetTimerInfo(pid, index: Longint): TTimerInfo;
var
	info: TTimerInfo;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(index > 0) and
		(index < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[index].timerOwner = -1)) then
		begin
			info.timerOwner := process[pid].processTimers[index].timerOwner;
			info.timerInterval := process[pid].processTimers[index].timerInterval;
			info.timerThreadId := process[pid].processTimers[index].timerThreadId;
			info.timerLastExecuted := process[pid].processTimers[index].timerLastExecuted;
			info.timerEnabled := process[pid].processTimers[index].timerEnabled;
			info.timerStarted := process[pid].processTimers[index].timerStarted;
		end;
	SyscallsGetTimerInfo := info;
end;

(*===returns the count of process parameters===*)
function SyscallsGetParametersCount(pid: Longint): Longint;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(Length(process[pid].processParameters) > 0) then
		SyscallsGetParametersCount := Length(process[pid].processParameters) - 1
	else
		SyscallsGetParametersCount := 0;
end;

(*===returns a process parameter with specified number===*)
function SyscallsGetParameter(pid, id: Longint): String;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(id > 0) and
		(id < Length(process[pid].processParameters)) then
		SyscallsGetParameter := process[pid].processParameters[id]
	else
		SyscallsGetParameter := '';
end;

(*===returns process info===*)
function SyscallsGetProcessInfo(pid: Longint): TProcessInfo;
begin
	if (pid > -1) and
		(pid < Length(process)) then
		begin
			with SyscallsGetProcessInfo do
				begin
					pName     := process[pid].processName;
					pTID      := process[pid].processMainThreadId;
					pDisplay  := process[pid].processDisplay;
					pState    := process[pid].processState;
					pUser     := process[pid].processUser;
					pParent   := process[pid].processParentPid;
					pSTime    := process[pid].processStartTime;
					pChildren := process[pid].processChildren;
				end;
		end
	else
		begin
			with SyscallsGetProcessInfo do
				begin
					pName    := '';
					pTID     := 0;
					pDisplay := -1;
					pState   := tps_none;
					pUser    := -1;
					pParent  := 0;
					pSTime   := 0;
					SetLength(pChildren, 0);
				end;
		end;
end;

(*===sets the process name===*)
function SyscallsSetProcessName(pid: Longint; name: String; accesskey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accesskey)) then
		begin
			EnterLock(process[pid].processLock);
			process[pid].processName := name;
			LeaveLock(process[pid].processLock);
			SyscallsSetProcessName := true;
		end
	else
		SyscallsSetProcessName := false;
end;

(*===finds process pid by its name===*)
function SyscallsFindProcess(name: String): Longint;
var
	i: Longint;
begin
	(*return 0 if not found*)
	SyscallsFindProcess := 0;
	for i := 0 to Length(process) - 1 do
		if process[i].processState = tps_running then
			if process[i].processName = name then
				begin
					(*returns only first process*)
					(*TODO: must return an array if several processes have same names*)
					SyscallsFindProcess := i;
					break;
				end;
end;

(*===returns process priority===*)
function SyscallsGetProcessPriority(pid: Longint): Longint;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) then
		begin
			SyscallsGetProcessPriority := ThreadGetPriority(process[pid].processMainThreadId);
		end
	else
		SyscallsGetProcessPriority := 0;
end;

(*===sets process priority===*)
function SyscallsSetProcessPriority(pid, priority: Longint): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(priority < 16) and
		(priority > -16) then
		SyscallsSetProcessPriority := ThreadSetPriority(process[pid].processMainThreadId, priority)
	else
		SyscallsSetProcessPriority := false;
end;

(*===exports process functions===*)
function SyscallsRegisterExports(pid: Longint; p: TExports; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running)  and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			EnterLock(process[pid].processLock);
			process[pid].processExports := p;
			LeaveLock(process[pid].processLock);
			SyscallsRegisterExports := true;
		end
	else
		SyscallsRegisterExports := false;
end;

(*===finds export by its name and owner's PID===*)
function SyscallsFindExport(pid: Longint; name: String): Longint;
var
	i: Longint;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(not (name = '')) and
		(process[pid].processState = tps_running) then
		begin
			SyscallsFindExport := 0;
			for i := 1 to Length(process[pid].processExports.te_pointers) - 1 do
				if (not (process[pid].processExports.te_pointers[i] = nil)) and
					(process[pid].processExports.te_names[i] = name) then
					begin
						(*TODO: return array of exports*)
						SyscallsFindExport := i;
						break;
					end;
		end
	else
		SyscallsFindExport := 0;
end;

(*===calls exported function===*)
function SyscallsCallExport(pid, id: Longint; args: TPointers): TPointers;
var
	proc: TProcessExportFunction;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) then
		begin
			pointer(proc) := process[pid].processExports.te_pointers[id];
			SyscallsCallExport := proc(args);
		end
	else
		begin
			SetLength(SyscallsCallExport, 2);
			SyscallsCallExport[1] := nil;
		end;
end;

(*===returns kernel info===*)
function SyscallsGetKernelInfo(a_null: Pointer): TKernelInfo;
begin
	with SyscallsGetKernelInfo do
		begin
			osName := kernel.kernelName;
			osVersion := kernel.kernelVersion;
			osCodeName := kernel.kernelCodeName;
			osInternalTimerInterval := kernel.kernelInternalTimerInterval;
			osRoot := kernel.kernelRoot;
			osHostname := kernel.kernelHostname;
			osFsTab := fs.kernelFsTab;
			osProcessQueueLength := Length(kernel.process) - 1;
			{$ifdef collect_lock_statistic}
				osLockInit := lock.nr_init;
				osLockEnter := lock.nr_enter;
				osLockLeave := lock.nr_leave;
				osLockDone := lock.nr_done;
				osLockWait := lock.nr_wait;
				osLockAsk := lock.nr_is;
			{$else}
				osLockInit := -1;
				osLockEnter := -1;
				osLockLeave := -1;
				osLockDone := -1;
				osLockWait := -1;
				osLockAsk := -1;
			{$endif}
		end;
end;

(*===sets internal timer interval===*)
function SyscallsSetInternalTimerInterval(pid, interval: Longint; accessKey: TAccessKey): Boolean;
begin
	if (interval > 0) and
		(interval < 1001) and
		(pid > 0) and
		(pid < Length(process)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(process[pid].processUser = 0) then
		begin
			kernel.kernelInternalTimerInterval := interval;
			SyscallsSetInternalTimerInterval := true;
		end
	else
		SyscallsSetInternalTimerInterval := false;
end;

(*===sends signal to process===*)
function SyscallsSendSignal(pid, rpid: Longint; signal: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > -1) and
		(rpid > -1) and
		(pid < Length(process)) and
		(rpid < Length(process)) and
		(process[pid].processState = tps_running) and
		(process[rpid].processState = tps_running) and
		((process[pid].processUser = process[rpid].processUser) or
		(process[pid].processUser = 0)) and
		(signal > -1) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			if (signal = 3) or
				(signal = 6) or
				(signal = 9) then
				begin
					SyscallsSendSignal := KillThread(process[rpid].processMainThreadId) = 0;
				end
					else
			if signal = 18 then
				begin
					SyscallsSendSignal := ResumeThread(process[rpid].processMainThreadId) = 0;
				end
					else
			if signal = 19 then
				begin
					SyscallsSendSignal := SuspendThread(process[rpid].processMainThreadId) = 0;
				end
					else
				begin
					EnterLock(process[pid].processLock);
					process[rpid].processSignal := signal;
					process[rpid].processSignalSender := pid;
					LeaveLock(process[pid].processLock);
					BeginThread(@managers.ManagersExecuteExternalSignalHandler, pointer(rpid));
					SyscallsSendSignal := true;
				end;
		end
	else
		SyscallsSendSignal := false;
end;

(*===sends message===*)
function SyscallsSendMessage(pid, rpid: Longint; message: Pointer; messageType: TMessageType; accessKey: TAccessKey): Boolean;
begin
	if (pid > -1) and
		(rpid > -1) and
		(pid < Length(process)) and
		(rpid < Length(process)) and
		(process[pid].processState = tps_running) and
		(process[rpid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accesskey)) then
		begin
			EnterLock(process[rpid].processMessageLock);
			process[rpid].processMessage.message := message;
			process[rpid].processMessage.messageType := messageType;
			process[rpid].processMessage.messageSender := pid;
			process[rpid].processMessage.messageId := now;
			EnterLock(managersLockMessages);
			BeginThread(@ManagersExecuteExternalMessageHandler, pointer(rpid));
			WaitLock(managersLockMessages);
			WaitLock(process[rpid].processMessageLock);
			SyscallsSendMessage := true;
		end
			else
		SyscallsSendMessage := false;
end;

(*===registers a process at display===*)
function SyscallsRegisterDisplay(pid, id: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(process[pid].processDisplay = -1) and
		(id >= 0) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			EnterLock(process[pid].processLock);
			process[pid].processDisplay := id;
			LeaveLock(process[pid].processLock);
			DisplayCreateDisplay(id);
			SyscallsRegisterDisplay := true;
		end
			else
		SyscallsRegisterDisplay := false;
end;

(*===unregisters a process from display===*)
function SyscallsUnRegisterDisplay(pid: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayDestroyDisplay(process[pid].processDisplay);
			EnterLock(process[pid].processLock);
			process[pid].processDisplay := -1;
			LeaveLock(process[pid].processLock);
			SyscallsUnRegisterDisplay := true;
		end
			else
		SyscallsUnRegisterDisplay := false;
end;

(*===assigns a display buffer===*)
function SyscallsAssignDisplayBuffer(pid: Longint; buffer: TDisplayLines; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accesskey)) then
		begin
			DisplayAssignBuffer(process[pid].processDisplay, buffer);
			SyscallsAssignDisplayBuffer := true;
		end
			else
		SyscallsAssignDisplayBuffer := false;
end;

(*===outputs text===*)
function SyscallsTextOut(pid: Longint; text: String; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayTextOut(text, process[pid].processDisplay);
			SyscallsTextOut := true;
		end
			else
		SyscallsTextOut := false;
end;

(*===outputs text with a new line===*)
function SyscallsTextOutLn(pid: Longint; text: String; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayTextOutLn(text, process[pid].processDisplay);
			SyscallsTextOutLn := true;
		end
			else
		SyscallsTextOutLn := false;
end;

(*===outputs parsed text===*)
function SyscallsTextOutParse(pid: Longint; text: String; accesskey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayTextOutParse(text, process[pid].processDisplay);
			SyscallsTextOutParse := true;
		end
			else
		SyscallsTextOutParse := false;
end;

(*===outputs text in specified place===*)
function SyscallsTextOutXy(pid, x, y: Longint; text: String; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(x >= 0) and
		(y >= 0) and
		(x <= 79) and
		(y <= 24) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayTextOutXy(text, process[pid].processDisplay, x, y);
			SyscallsTextOutXy := true;
		end
			else
		SyscallsTextOutXy := false;
end;

(*===deletes last line at display===*)
function SyscallsDeleteLastLine(pid: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayDeleteLastLine(process[pid].processDisplay);
			SyscallsDeleteLastLine := true;
		end
			else
		SyscallsDeleteLastLine := false;
end;

(*===deletes last symbol on display===*)
function SyscallsDeleteLastSymbol(pid: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			DisplayDeleteLastSymbol(process[pid].processDisplay);
			SyscallsDeleteLastSymbol := true;
		end
			else
		SyscallsDeleteLastSymbol := false;
end;

(*===clears display===*)
function SyscallsClearDisplay(pid: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (process[pid].processDisplay = -1)) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accesskey)) then
		begin
			DisplayClearDisplay(process[pid].processDisplay);
			SyscallsClearDisplay := true;
		end
			else
		SyscallsClearDisplay := false;
end;

(*===returns current display number===*)
function SyscallsGetCurrentDisplay(a_null: Pointer): Longint;
begin
	SyscallsGetCurrentDisplay := DisplayGetCurrentDisplay;
end;

(*===returns first empty display number===*)
function SyscallsGetEmptyDisplay(a_null: Pointer): Longint;
begin
	SyscallsGetEmptyDisplay := DisplayGetEmptyDisplay;
end;

(*===returns parent display number===*)
function SyscallsGetParentDisplay(pid: Longint): Longint;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) then
		begin
			SyscallsGetParentDisplay := process[pid].processParentDisplay;
		end
			else
		SyscallsGetParentDisplay := -1;
end;

(*===returns current directory===*)
function SyscallsGetCurrentDirectory(pid: Longint): String;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) then
		begin
			SyscallsGetCurrentDirectory := process[pid].processCurrentDirectory;
		end
			else
		SyscallsGetCurrentDirectory := '';
end;

(*===sets current directory===*)
function SyscallsSetCurrentDirectory(pid: Longint; dir: String; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(not (dir = '')) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) then
		begin
			EnterLock(process[pid].processLock);
			process[pid].processCurrentDirectory := dir;
			LeaveLock(process[pid].processLock);
			SyscallsSetCurrentDirectory := true;
		end
			else
		SyscallsSetCurrentDirectory := false;
end;

(*===sets machine hostname===*)
function SyscallsSetHostname(pid: Longint; hostName: String; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(process[pid].processUser = 0) then
		begin
			kernel.kernelHostname := hostName;
			SyscallsSetHostname := true;
		end
			else
		SyscallsSetHostname := false;
end;

(*===converts VFS filename to DOS filename===*)
function SyscallsFsGetDOSPath(vfsFileName: String): String;
begin
	if not (vfsFileName = '') then
		SyscallsFsGetDOSPath := fs.StreamFSToDOS(vfsFileName)
	else
		SyscallsFsGetDOSPath := '';
end;

(*===checks file existing===*)
function SyscallsFsFileExists(filePath: String; fileType: TFileType): Boolean;
begin
	if not (filePath = '') then
		SyscallsFsFileExists := fs.FsFileExists(filePath, fileType)
	else
		SyscallsFsFileExists := false;
end;

(*===adds new mount record===*)
function SyscallsFsAddFsTabRecord(pid: Longint; fsTabRecord: TFsTabRecord; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(process[pid].processUser = 0) then
		begin
			SyscallsFsAddFsTabRecord := fs.FsAddToFsTab(fsTabRecord.source, fsTabRecord.mountPoint, fsTabRecord.fileSystem, fsTabRecord.options);
		end
			else
		SyscallsFsAddFsTabRecord := false;
end;

(*===adds new application timer===*)
function SyscallsAddApplicationTimer(pid: Longint; timerProcedure: Pointer; timerInterval: Longint; timerEnabled: Boolean; accessKey: TAccessKey): Longint;
var
	timerIndex: Longint;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(not (timerProcedure = nil)) and
		(timerInterval > 0) then
		begin
			timerIndex := 0;
			repeat
				Inc(timerIndex);
			until (timerIndex > Length(process[pid].processTimers)) or
					(process[pid].processTimers[timerIndex].timerOwner = -1);
			if timerIndex > Length(process[pid].processTimers) then
				begin
					SetLength(process[pid].processTimers, Length(process[pid].processTimers) + 1);
					timerIndex := Length(process[pid].processTimers) - 1;
				end;
			pointer(process[pid].processTimers[timerIndex].timerProcedure) := timerProcedure;
			process[pid].processTimers[timerIndex].timerInterval := timerInterval;
			process[pid].processTimers[timerIndex].timerEnabled := timerEnabled;
			process[pid].processTimers[timerIndex].timerLastExecuted := 0;
			process[pid].processTimers[timerIndex].timerOwner := pid;
			process[pid].processTimerIdProcessing := timerIndex;
			if timerEnabled then
				begin
					EnterLock(managersLockTimers);
					EnterLock(process[pid].processTimerIdProcessingLock);
					process[pid].processTimers[timerIndex].timerThreadId := BeginThread(@ManagersExecuteExternalTimer, pointer(pid));
					WaitLock(process[pid].processTimerIdProcessingLock);
					WaitLock(managersLockTimers);
					process[pid].processTimers[timerIndex].timerStarted := true;
				end;
			SyscallsAddApplicationTimer := timerIndex;
		end
			else
		SyscallsAddApplicationTimer := 0;
end;

(*===removes application timer===*)
function SyscallsRemoveApplicationTimer(pid, id: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(id > 0) and
		(id < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[id].timerOwner = -1)) then
		begin
			if process[pid].processTimers[id].timerStarted then
				KillThread(process[pid].processTimers[id].timerThreadId);
			with process[pid].processTimers[id] do
				begin
					timerEnabled := false;
					timerStarted := false;
					timerThreadId := 0;
					timerProcedure := nil;
					timerInterval := 0;
					timerLastExecuted := 0;
					timerOwner := -1;
				end;
			if id = Length(process[pid].processTimers) - 1 then
				SetLength(process[pid].processTimers, Length(process[pid].processTimers) - 1);
			SyscallsRemoveApplicationTimer := true;
		end
			else
				SyscallsRemoveApplicationTimer := false;
end;

(*===resumes application timer===*)
function SyscallsResumeApplicationTimer(pid, id: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(id > 0) and
		(id < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[id].timerOwner = -1)) then
		begin
			ResumeThread(process[pid].processTimers[id].timerThreadId);
			process[pid].processTimers[id].timerEnabled := true;
			SyscallsResumeApplicationTimer := true;
		end
			else
				SyscallsResumeApplicationTimer := false;
end;

(*===suspends application timer===*)
function SyscallsSuspendApplicationTimer(pid, id: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(id > 0) and
		(id < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[id].timerOwner = -1)) then
		begin
			SuspendThread(process[pid].processTimers[id].timerThreadId);
			process[pid].processTimers[id].timerEnabled := false;
			SyscallsSuspendApplicationTimer := true;
		end
			else
				SyscallsSuspendApplicationTimer := false;
end;

(*===sets interval of application timer===*)
function SyscallsSetApplicationTimerInterval(pid, id, timerInterval: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(id > 0) and
		(id < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[id].timerOwner = -1)) and
		(timerInterval > 0) then
		begin
			process[pid].processTimers[id].timerInterval := timerInterval;
			SyscallsSetApplicationTimerInterval := true;
		end
			else
				SyscallsSetApplicationTimerInterval := false;
end;

function SyscallsInvokeApplicationTimer(pid, id: Longint; accessKey: TAccessKey): Boolean;
begin
	if (pid > 0) and
		(pid < Length(process)) and
		(process[pid].processState = tps_running) and
		(tools.ToolsCompareAccessKeys(process[pid].processAccessKey, accessKey)) and
		(id > 0) and
		(id < Length(process[pid].processTimers)) and
		(not (process[pid].processTimers[id].timerOwner = -1)) and
		(not process[pid].processTimers[id].timerStarted) then
		begin
			EnterLock(managersLockTimers);
			EnterLock(process[pid].processTimerIdProcessingLock);
			process[pid].processTimers[id].timerThreadId := BeginThread(@ManagersExecuteExternalTimer, pointer(pid));
			WaitLock(process[pid].processTimerIdProcessingLock);
			WaitLock(managersLockTimers);
			process[pid].processTimers[id].timerStarted := true;
			SyscallsInvokeApplicationTimer := true;
		end
			else
				SyscallsInvokeApplicationTimer := false;
end;


begin
end.

