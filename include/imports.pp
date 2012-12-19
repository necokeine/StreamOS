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
	imports;

interface

uses
	stypes;

var
	kernelProcessCreate               : function(filename: String; parameters: TDynamicStringList; parentPid, user: Longint; accessKey: TAccessKey): Longint;
	kernelGetTimerInfo                : function(pid, index: Longint): TTimerInfo;
	kernelGetParametersCount          : function(pid: Longint): Longint;
	kernelGetParameter                : function(pid, id: Longint): String;
	kernelGetProcessInfo              : function(pid: Longint): TProcessInfo;
	kernelSetProcessName              : function(pid: Longint; name: String; accessKey: TAccessKey): Boolean;
	kernelFindProcess                 : function(name: String): Longint;
	kernelGetProcessPriority          : function(pid: Longint): Longint;
	kernelSetProcessPriority          : function(pid, priority: Longint): Boolean;
	kernelRegisterExports             : function(pid: Longint; p: TExports; accessKey: TAccessKey): Boolean;
	kernelFindExport                  : function(pid: Longint; name: String): Longint;
	kernelCallExport                  : function(pid, id: Longint; args: TPointers): TPointers;
	kernelGetKernelInfo               : function(a_null: Pointer): TKernelInfo;
	kernelSetInternalTimerInterval    : function(pid, interval: Longint; accessKey: TAccessKey): Boolean;
	kernelSendSignal                  : function(pid, rpid: Longint; signal: Longint; accessKey: TAccessKey): Boolean;
	kernelSendMessage                 : function(pid, rpid: Longint; message: Pointer; messageType: TMessageType; accessKey: TAccessKey): Boolean;
	kernelRegisterDisplay             : function(pid, id: Longint; accessKey: TAccessKey): Boolean;
	kernelUnregisterDisplay           : function(pid: Longint; accessKey: TAccessKey): Boolean;
	kernelAssignDisplayBuffer         : function(pid: Longint; buffer: TPointers; accessKey: TAccessKey): Boolean;
	kernelTextOut                     : function(pid: Longint; text: String; accessKey: TAccessKey): Boolean;
	kernelTextOutLn                   : function(pid: Longint; text: String; accessKey: TAccessKey): Boolean;
	kernelTextOutParse                : function(pid: Longint; text: String; accessKey: TAccessKey): Boolean;
	kernelTextOutXY                   : function(pid, x, y: Longint; text: String; accessKey: TAccessKey): Boolean;
	kernelDeleteLastLine              : function(pid: Longint; accessKey: TAccessKey): Boolean;
	kernelDeleteLastSymbol            : function(pid: Longint; accessKey: TAccessKey): Boolean;
	kernelClearDisplay                : function(pid: Longint; accessKey: TAccessKey): Boolean;
	kernelGetCurrentDisplay           : function(a_null: Pointer): Longint;
	kernelGetEmptyDisplay             : function(a_null: Pointer): Longint;
	kernelGetParentDisplay            : function(pid: Longint): Longint;
	kernelGetCurrentDirectory         : function(pid: Longint): String;
	kernelSetCurrentDirectory         : function(pid: Longint; dir: String; accessKey: TAccessKey): Boolean;
	kernelSetHostName                 : function(pid: Longint; hostname: String; accessKey: TAccessKey): Boolean;
	kernelFsGetDosPath                : function(vfsfilename: String): String;
	kernelFsFileExists                : function(filepath: String; filetype: TFileType): Boolean;
	kernelFsAddFstabRecord            : function(pid: Longint; fstabrecord:tfstabrecord; accessKey: TAccessKey): Boolean;
	kernelAddApplicationTimer         : function(pid: Longint; timerProcedure: Pointer; timerInterval: Longint; timerEnabled: Boolean; accessKey: TAccessKey): Longint;
	kernelRemoveApplicationTimer      : function(pid, id: Longint; accessKey: TAccessKey): Boolean;
	kernelResumeApplicationTimer      : function(pid, id: Longint; accessKey: TAccessKey): Boolean;
	kernelSuspendApplicationTimer     : function(pid, id: Longint; accessKey: TAccessKey): Boolean;
	kernelSetApplicationTimerInterval : function(pid, id, timerInterval: Longint; accessKey: TAccessKey): Boolean;
	kernelInvokeApplicationTimer      : function(pid, id: Longint; accessKey: TAccessKey): Boolean;

	currentPid: Longint;
	currentAccessKey: TAccessKey;

procedure ImportsImportSystemCalls(systemCallsTable: TSystemCalls; mypid: Longint; myaccessKey: TAccessKey);

function ProcessCreate               (fileName: String; parameters: TDynamicStringList; parentPid, user: Longint): Longint;
function GetTimerInfo                (index: Longint): TTimerInfo;
function GetParametersCount          : Longint;
function GetParameter                (id: Longint): String;
function GetProcessInfo              : TProcessInfo;
function SetProcessName              (name: String): Boolean;
function FindProcess                 (name: String): Longint;
function GetProcessPriority          : Longint;
function SetProcessPriority          (priority: Longint): Boolean;
function RegisterExports             (p: TExports): Boolean;
function FindExport                  (pid: Longint; name: String): Longint;
function CallExport                  (pid, id: Longint; args: TPointers): TPointers;
function GetKernelInfo               : TKernelInfo;
function SetInternalTimerInterval    (interval: Longint): Boolean;
function SendSignal                  (rpid: Longint; signal: Longint): Boolean;
function SendMessage                 (rpid: Longint; message: Pointer; messageType: TMessageType): Boolean;
function RegisterDisplay             (id: Longint): Boolean;
function UnregisterDisplay           : Boolean;
function AssignDisplayBuffer         (buffer: TPointers): Boolean;
function TextOut                     (text: String): Boolean;
function TextOutLn                   (text: String): Boolean;
function TextOutParse                (text: String): Boolean;
function TextOutXY                   (x, y: Longint; text: String): Boolean;
function DeleteLastLine              : Boolean;
function DeleteLastSymbol            : Boolean;
function ClearDisplay                : Boolean;
function GetCurrentDisplay           : Longint;
function GetEmptyDisplay             : Longint;
function GetParentDisplay            : Longint;
function GetCurrentDirectory         : String;
function SetCurrentDirectory         (dir: String): Boolean;
function SetHostName                 (hostName: String): Boolean;
function FsGetDosPath                (vfsFileName: String): String;
function FsFileExists                (filePath: String; fileType: TFileType): Boolean;
function FsAddFstabRecord            (fstabRecord: TFstabRecord): Boolean;
function AddApplicationTimer         (timerProcedure: Pointer; timerInterval: Longint; timerEnabled: Boolean): Longint;
function RemoveApplicationTimer      (id: Longint): Boolean;
function ResumeApplicationTimer      (id: Longint): Boolean;
function SuspendApplicationTimer     (id: Longint): Boolean;
function SetApplicationTimerInterval (id, timerInterval: Longint): Boolean;
function InvokeApplicationTimer      (id: Longint): Boolean;

implementation

procedure ImportsImportSystemCalls(systemCallsTable: TSystemCalls; myPid: Longint; myAccessKey: TAccessKey);


function FindSystemCall(name: String): Longint;
var
	k: Longint;
begin
	FindSystemCall := 0;
	for k := 1 to Length(systemCallsTable) - 1 do
		if systemCallsTable[k].tsc_name = name then
			begin
				findSystemCall := k;
				break;
			end;
end;

begin
	pointer(kernelProcessCreate)               := systemCallsTable[FindSystemCall('processcreate')].tsc_pointer;
	pointer(kernelGetTimerInfo)                := systemCallsTable[FindSystemCall('gettimerinfo')].tsc_pointer;
	pointer(kernelGetParametersCount)          := systemCallsTable[FindSystemCall('getparameterscount')].tsc_pointer;
	pointer(kernelGetParameter)                := systemCallsTable[FindSystemCall('getparameter')].tsc_pointer;
	pointer(kernelGetProcessInfo)              := systemCallsTable[FindSystemCall('getprocessinfo')].tsc_pointer;
	pointer(kernelSetProcessName)              := systemCallsTable[FindSystemCall('setprocessname')].tsc_pointer;
	pointer(kernelFindProcess)                 := systemCallsTable[FindSystemCall('findprocess')].tsc_pointer;
	pointer(kernelGetProcessPriority)          := systemCallsTable[FindSystemCall('getprocesspriority')].tsc_pointer;
	pointer(kernelSetProcessPriority)          := systemCallsTable[FindSystemCall('setprocesspriority')].tsc_pointer;
	pointer(kernelRegisterExports)             := systemCallsTable[FindSystemCall('registerexports')].tsc_pointer;
	pointer(kernelFindExport)                  := systemCallsTable[FindSystemCall('findexport')].tsc_pointer;
	pointer(kernelCallExport)                  := systemCallsTable[FindSystemCall('callexport')].tsc_pointer;
	pointer(kernelGetKernelInfo)               := systemCallsTable[FindSystemCall('getkernelinfo')].tsc_pointer;
	pointer(kernelSetInternalTimerInterval)    := systemCallsTable[FindSystemCall('setinternaltimerinterval')].tsc_pointer;
	pointer(kernelSendSignal)                  := systemCallsTable[FindSystemCall('sendsignal')].tsc_pointer;
	pointer(kernelSendMessage)                 := systemCallsTable[FindSystemCall('sendmessage')].tsc_pointer;
	pointer(kernelRegisterDisplay)             := systemCallsTable[FindSystemCall('registerdisplay')].tsc_pointer;
	pointer(kernelUnregisterDisplay)           := systemCallsTable[FindSystemCall('unregisterdisplay')].tsc_pointer;
	pointer(kernelAssignDisplayBuffer)         := systemCallsTable[FindSystemCall('assigndisplaybuffer')].tsc_pointer;
	pointer(kernelTextOut)                     := systemCallsTable[FindSystemCall('textout')].tsc_pointer;
	pointer(kernelTextOutLn)                   := systemCallsTable[FindSystemCall('textoutln')].tsc_pointer;
	pointer(kernelTextOutParse)                := systemCallsTable[FindSystemCall('textoutparse')].tsc_pointer;
	pointer(kernelTextOutXY)                   := systemCallsTable[FindSystemCall('textoutxy')].tsc_pointer;
	pointer(kernelDeleteLastLine)              := systemCallsTable[FindSystemCall('deletelastline')].tsc_pointer;
	pointer(kernelDeleteLastSymbol)            := systemCallsTable[FindSystemCall('deletelastsymbol')].tsc_pointer;
	pointer(kernelClearDisplay)                := systemCallsTable[FindSystemCall('cleardisplay')].tsc_pointer;
	pointer(kernelGetCurrentDisplay)           := systemCallsTable[FindSystemCall('getcurrentdisplay')].tsc_pointer;
	pointer(kernelGetEmptyDisplay)             := systemCallsTable[FindSystemCall('getemptydisplay')].tsc_pointer;
	pointer(kernelGetParentDisplay)            := systemCallsTable[FindSystemCall('getparentdisplay')].tsc_pointer;
	pointer(kernelGetCurrentDirectory)         := systemCallsTable[FindSystemCall('getcurrentdirectory')].tsc_pointer;
	pointer(kernelSetCurrentDirectory)         := systemCallsTable[FindSystemCall('setcurrentdirectory')].tsc_pointer;
	pointer(kernelSetHostName)                 := systemCallsTable[FindSystemCall('sethostname')].tsc_pointer;
	pointer(kernelFsGetDosPath)                := systemCallsTable[FindSystemCall('fsgetdospath')].tsc_pointer;
	pointer(kernelFsFileExists)                := systemCallsTable[FindSystemCall('fsfileexists')].tsc_pointer;
	pointer(kernelFsAddFstabRecord)            := systemCallsTable[FindSystemCall('fsaddfstabrecord')].tsc_pointer;
	pointer(kernelAddApplicationTimer)         := systemCallsTable[FindSystemCall('addapplicationtimer')].tsc_pointer;
	pointer(kernelRemoveApplicationTimer)      := systemCallsTable[FindSystemCall('removeapplicationtimer')].tsc_pointer;
	pointer(kernelResumeApplicationTimer)      := systemCallsTable[FindSystemCall('resumeapplicationtimer')].tsc_pointer;
	pointer(kernelSuspendApplicationTimer)     := systemCallsTable[FindSystemCall('suspendapplicationtimer')].tsc_pointer;
	pointer(kernelSetApplicationTimerInterval) := systemCallsTable[FindSystemCall('setapplicationtimerinterval')].tsc_pointer;
	pointer(kernelInvokeApplicationTimer)      := systemCallsTable[FindSystemCall('invokeapplicationtimer')].tsc_pointer;

	currentPid := myPid;
	currentAccessKey := myaccessKey;
end;

function ProcessCreate(filename: String; parameters: TDynamicStringList; parentPid, user: Longint): Longint;
begin
	ProcessCreate := kernelProcessCreate(filename, parameters, parentpid, user, currentAccessKey);
end;

function GetTimerInfo(index: Longint): TTimerInfo;
begin
	GetTimerInfo := kernelGetTimerInfo(currentPid, index);
end;

function GetParametersCount: Longint;
begin
	GetParametersCount := KernelGetParametersCount(currentPid);
end;

function GetParameter(id: Longint): String;
begin
	GetParameter := KernelGetParameter(currentPid, id);
end;

function GetProcessInfo: TProcessInfo;
begin
	GetProcessInfo := KernelGetProcessInfo(currentPid);
end;

function SetProcessName(name: String): Boolean;
begin
	SetProcessName := KernelSetProcessName(currentPid, name, currentAccessKey);
end;

function FindProcess(name: String): Longint;
begin
	FindProcess := KernelFindProcess(name);
end;

function GetProcessPriority: Longint;
begin
	GetProcessPriority := KernelGetProcessPriority(currentPid);
end;

function SetProcessPriority(priority: Longint): Boolean;
begin
	SetProcessPriority := KernelSetProcessPriority(currentPid, priority);
end;

function registerexports(p : TExports): Boolean;
begin
	RegisterExports := KernelRegisterExports(currentPid, p, currentAccessKey);
end;

function FindExport(pid: Longint; name: String): Longint;
begin
	FindExport := KernelFindExport(pid, name);
end;

function CallExport(pid, id: Longint; args: TPointers): TPointers;
begin
	CallExport := KernelCallExport(pid, id, args);
end;

function GetKernelInfo: TKernelInfo;
begin
	GetKernelInfo := KernelGetKernelInfo(nil);
end;

function SetInternalTimerInterval(interval: Longint): Boolean;
begin
	SetInternalTimerInterval := KernelSetInternalTimerInterval(currentPid, interval, currentAccessKey);
end;

function SendSignal(rpid: Longint; signal: Longint): Boolean;
begin
	SendSignal := KernelSendSignal(currentPid, rpid, signal, currentAccessKey);
end;

function SendMessage(rpid: Longint; message: Pointer; messageType: TMessageType): Boolean;
begin
	SendMessage := KernelSendMessage(currentPid, rpid, message, messageType, currentAccessKey);
end;

function RegisterDisplay(id: Longint): Boolean;
begin
	RegisterDisplay := KernelRegisterDisplay(currentPid, id, currentAccessKey);
end;

function UnregisterDisplay: Boolean;
begin
	UnregisterDisplay := KernelUnregisterDisplay(currentPid, currentAccessKey);
end;

function AssignDisplayBuffer(buffer: TPointers): Boolean;
begin
	AssignDisplayBuffer := KernelAssignDisplayBuffer(currentPid, buffer, currentAccessKey);
end;

function TextOut(text: String): Boolean;
begin
	TextOut := KernelTextOut(currentPid, text, currentAccessKey);
end;

function TextOutLn(text: String): Boolean;
begin
	TextOutLn := KernelTextOutLn(currentPid, text, currentAccessKey);
end;

function textoutparse(text: String): Boolean;
begin
	TextOutParse := KernelTextOutParse(currentPid, text, currentAccessKey);
end;

function TextOutXY(x, y: Longint; text: String): Boolean;
begin
	TextOutXY := KernelTextOutXY(currentPid, x, y, text, currentAccessKey);
end;

function DeleteLastLine: Boolean;
begin
	DeleteLastLine := KernelDeleteLastLine(currentPid, currentAccessKey);
end;

function DeleteLastSymbol: Boolean;
begin
	DeleteLastSymbol := KernelDeleteLastSymbol(currentPid, currentAccessKey);
end;

function ClearDisplay: Boolean;
begin
	ClearDisplay := KernelClearDisplay(currentPid, currentAccessKey);
end;

function GetCurrentDisplay: Longint;
begin
	GetCurrentDisplay := KernelGetCurrentDisplay(nil);
end;

function GetEmptyDisplay: Longint;
begin
	GetEmptyDisplay := KernelGetEmptyDisplay(nil);
end;

function GetParentDisplay: Longint;
begin
	GetParentDisplay := KernelGetParentDisplay(currentPid);
end;

function GetCurrentDirectory: String;
begin
	GetCurrentDirectory := KernelGetCurrentDirectory(currentPid);
end;

function SetCurrentDirectory(dir: String): Boolean;
begin
	SetCurrentDirectory := KernelSetCurrentDirectory(currentPid, dir, currentAccessKey);
end;

function SetHostName(hostName: String): Boolean;
begin
	SetHostName := KernelSetHostname(currentPid, hostname, currentAccessKey);
end;

function FsGetDosPath(VfsFileName: String): String;
begin
	FsGetDosPath := KernelFsGetDosPath(VfsFileName);
end;

function FsFileExists(filePath: String; fileType: TFileType): Boolean;
begin
	FsFileExists := KernelFsFileExists(filePath, fileType);
end;

function FsAddFstabRecord(FstabRecord: TFstabRecord): Boolean;
begin
	FsAddFstabRecord := KernelFsAddFstabRecord(currentPid, FstabRecord, currentAccessKey);
end;

function AddApplicationTimer(timerProcedure: Pointer; timerInterval: Longint; timerEnabled: Boolean): Longint;
begin
	AddApplicationTimer := kernelAddApplicationTimer(currentPid, timerProcedure, timerInterval, timerEnabled, currentAccessKey);
end;

function RemoveApplicationTimer(id: Longint): Boolean;
begin
	RemoveApplicationTimer := kernelRemoveApplicationTimer(currentPid, id, currentAccessKey);
end;

function ResumeApplicationTimer(id: Longint): Boolean;
begin
	ResumeApplicationTimer := kernelResumeApplicationTimer(currentPid, id, currentAccessKey);
end;

function SuspendApplicationTimer(id: Longint): Boolean;
begin
	SuspendApplicationTimer := kernelSuspendApplicationTimer(currentPid, id, currentAccessKey);
end;

function SetApplicationTimerInterval(id, timerInterval: Longint): Boolean;
begin
	SetApplicationTimerInterval := kernelSetApplicationTimerInterval(currentPid, id, timerInterval, currentAccessKey);
end;

function InvokeApplicationTimer(id: Longint): Boolean;
begin
	InvokeApplicationTimer := kernelInvokeApplicationTimer(currentPid, id, currentAccessKey);
end;

end.

