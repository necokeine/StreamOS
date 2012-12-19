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
	managers;

(*module executes kernel internal threads*)

interface

uses
	stypes;

function ManagersExecuteExternalKeyHandler(p: Pointer): Longint;
function ManagersExecuteInternalKeyHandler(p: Pointer): Longint;
function ManagersExecuteExternalMessageHandler(p: Pointer): Longint;
function ManagersExecuteExternalSignalHandler(p: Pointer): Longint;
function ManagersExecuteSingleExternal(p: Pointer): Longint;
function ManagersExecuteExternal(p: Pointer): Longint;
function ManagersExecuteExternalTimer(p: Pointer): Longint;

var
	managersLockMessages, managersLockTimers, managersLockKeys, managersLockExternal, managersLockSingleExternal: TLockContainer;

implementation

uses
	keyboard,
	kernel,
	modules,
	errorman,
	sysutils,
	syscalls,
	lock,
	tools;

(*===executes external keypress handlers===*)
function ManagersExecuteExternalKeyHandler(p: Pointer): Longint;
var
	rpid: Longint;
	ch: Char;
begin
	ManagersExecuteExternalKeyHandler := 0;
	rpid := -1;
	try
		pointer(rpid) := p;
		LeaveLock(managersLockKeys);
		ch := process[rpid].processKey;
		LeaveLock(process[rpid].processKeyLock);
		process[rpid].processOnKeyHandlerProcedure(ch);
	except
		on e: Exception do
			begin
				if IsLocked(managersLockKeys) then
					LeaveLock(managersLockKeys);
				if (not (rpid = -1)) and
					(IsLocked(process[rpid].processKeyLock)) then
					LeaveLock(process[rpid].processKeyLock);
				errorman.ErrormanRaiseKernelError(2, e.message);
			end;
	end;
end;

(*===executes application timer===*)
function ManagersExecuteExternalTimer(p: Pointer): Longint;
var
	rid, timerIndex: Longint;
begin
	ManagersExecuteExternalTimer := 0;
	rid := -1;
	try
		pointer(rid) := p;
		timerIndex := process[rid].processTimerIdProcessing;
		LeaveLock(managersLockTimers);
		LeaveLock(process[rid].processTimerIdProcessingLock);
		repeat
			process[rid].processTimers[timerIndex].timerProcedure;
			process[rid].processTimers[timerIndex].timerLastExecuted := now;
			Sleep(process[rid].processTimers[timerIndex].timerInterval);
		until false;
	except
		on e: Exception do
			begin
				if IsLocked(managersLockTimers) then
					LeaveLock(managersLockTimers);
				if (not (rid = -1)) and
					(IsLocked(process[rid].processTimerIdProcessingLock)) then
					LeaveLock(process[rid].processTimerIdProcessingLock);
				errorman.ErrormanRaiseKernelError(2, e.message);
			end;
	end;
end;

(*===executes internal keypress handler===*)
function ManagersExecuteInternalKeyHandler(p: Pointer): Longint;
var
	ch: Char;
	ke: TKeyEvent;
	k, transfer_k: Longint;
begin
	ManagersExecuteInternalKeyHandler := 0;
	repeat
		(*wait and get pressed key*)
		ke := TranslateKeyEvent(GetKeyEvent);
		ch := GetKeyEventChar(ke);
		(*system keys*)
		if ch = #17 then (*CTRL+q switches between displays*)
			DisplaySwitchDisplay
		else
			begin
				(*lock is used to ensure that process queue has not been changed*)
				EnterLock(kernel.kernelProcessQueueLock);
				(*transmit pressed key to all applications executed on current display*)
				for k := 1 to Length(process) - 1 do
					if (kernel.process[k].processState = tps_running) and
						(not (kernel.process[k].processName = '')) and
						(kernel.process[k].processDisplay = DisplayGetCurrentDisplay) then
						begin
							EnterLock(process[k].processKeyLock);
							kernel.process[k].processKey := ch;
							transfer_k := k;
							(*locks thread procedure to ensure that key is transmitted*)
							EnterLock(managersLockKeys);
							BeginThread(@ManagersExecuteExternalKeyHandler, pointer(transfer_k));
							WaitLock(managersLockKeys);
						end;
				LeaveLock(kernel.kernelProcessQueueLock);
			end;
	until false;
end;

(*===executes external message handlers===*)
function ManagersExecuteExternalMessageHandler(p: Pointer): Longint;
var
	rpid: Longint;
	_message: TMessage;
begin
	ManagersExecuteExternalMessageHandler := 0;
	rpid := -1;
	try
		pointer(rpid) := p;
		LeaveLock(managersLockMessages);
		(*get the message*)
		_message.message := kernel.process[rpid].processMessage.message;
		_message.messageId := kernel.process[rpid].processMessage.messageId;
		_message.messageType := kernel.process[rpid].processMessage.messageType;
		_message.messageSender := kernel.process[rpid].processMessage.messageSender;
		LeaveLock(kernel.process[rpid].processMessageLock);
		(*launches handler*)
		kernel.process[rpid].processOnMessageHandlerProcedure(_message);
	except
		on e: Exception do
			begin
				if IsLocked(managersLockMessages) then
					LeaveLock(managersLockMessages);
				if (not (rpid = -1)) and
					(IsLocked(process[rpid].processMessageLock)) then
					LeaveLock(process[rpid].processMessageLock);
				errorman.ErrormanRaiseKernelError(2, e.message);
			end;
	end;
end;

(*===executes external signal handlers===*)
function ManagersExecuteExternalSignalHandler(p: Pointer): Longint;
var
	rpid: Longint;
begin
	ManagersExecuteExternalSignalHandler := 0;
	try
		pointer(rpid) := p;
		kernel.process[rpid].processOnSignalHandlerProcedure(kernel.process[rpid].processSignal, kernel.process[rpid].processSignalSender);
	except
		on e: Exception do
			errorman.ErrormanRaiseKernelError(2, e.message);
	end;
end;

(*===executes main process procedure===*)
function ManagersExecuteSingleExternal(p: Pointer): Longint;
var
	pid: Longint;
begin
	ManagersExecuteSingleExternal := 0;
	pointer(pid) := p;
	LeaveLock(managersLockSingleExternal);
	try
		process[pid].ProcessMainThreadProcedure(pid, syscalls.systemCallsTable, kernel.process[pid].processAccessKey);
	except
		on e: Exception do
			errorman.ErrormanRaiseKernelError(2, e.message);
	end;
end;

(*===creates main process thread===*)
function ManagersExecuteExternal(p: Pointer): Longint;
var
	pid: Longint;
begin
	ManagersExecuteExternal := 0;
	pointer(pid) := p;
	EnterLock(managersLockSingleExternal);
	(*start separate thread for process*)
	kernel.process[pid].processMainThreadId := beginthread(@ManagersExecuteSingleExternal, pointer(pid));
	WaitLock(managersLockSingleExternal);
	LeaveLock(managersLockExternal);
	(*waits for process to be killed or exited*)
	WaitForThreadTerminate(process[pid].processMainThreadId, 0);
	kernel.KernelProcessDestroy(pid);
end;

begin
end.

