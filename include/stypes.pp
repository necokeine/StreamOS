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
	stypes;

interface

{$i config.inc}

const
	accessKeyLength = 64;
	maxY = 25;

type
	{$ifdef critical_lock}
		TLockContainer = record
				cs: TRTLCriticalSection;
				locked: Boolean;
			end;
	{$endif}
	{$ifdef standard_lock}
		TLockContainer = Boolean;
	{$endif}
	{$ifdef spin_lock}
		TLockContainer = Longint;
	{$endif}
	{$ifdef spin_atomic_lock}
		TLockContainer = Longint;
	{$endif}
	TMessageType = (tmt_widestring, tmt_longint, tmt_extended, tmt_boolean, tmt_pointer);
	TMessage = record
			messageSender: Longint;
			messageId: Extended;
			messageType: TMessageType;
			message: Pointer;
		end;
	TFsTabRecord = record
			source, mountpoint, filesystem, options:string;
		end;
	TFsTabRecords = array of TFsTabRecord;
	TPointers = array of Pointer;
	TSystemCall = record
			tsc_pointer: Pointer;
			tsc_name: String;
		end;
	TSystemCalls = array of TSystemCall;
	TDynamicStringList = array of String;
	TExports = record
			te_pointers: TPointers;
			te_names: TDynamicStringList;
		end;
	TProcessState= (tps_none, tps_running, tps_creating, tps_destroying);
	TAccessKey= array[1..accessKeyLength] of Byte;
	TProcessMainProcedure = procedure(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);
	TProcessExportFunction = function(args: TPointers): TPointers;
	TProcessOnKeyHandlerProcedure = procedure(tranCode: Char);
	TProcessOnMessageHandlerProcedure = procedure(message: TMessage);
	TProcessOnSignalHandlerProcedure = procedure(signal, sender: Longint);
	TKernelInfo = record
			osName, osVersion, osCodeName, osRoot, osHostname: String;
			osInternalTimerInterval, osProcessQueueLength: Longint;
			osLockInit, osLockEnter, osLockLeave, osLockDone, osLockWait, osLockAsk: Longint;
			osFsTab: TFsTabRecords;
		end;
	TProcessChildren = array of Longint;
	TProcessInfo = record
			pName: String;
			pUser, pTID, pDisplay, pParent: Longint;
			pState: TProcessState;
			pSTime: Extended;
			pChildren: TProcessChildren;
		end;
	TDisplayLines= array[1..maxY] of String;
	TFileType= (tft_file, tft_directory);
	TTimerProcedure = procedure;
	TTimer = record
			timerProcedure: TTimerProcedure;
			timerInterval, timerOwner: Longint;
			timerLastExecuted: Extended;
			timerEnabled, timerStarted: Boolean;
			timerThreadId: TThreadId;
		end;
	TTimerInfo = record
			timerInterval, timerOwner: Longint;
			timerLastExecuted: Extended;
			timerEnabled, timerStarted: Boolean;
			timerThreadId: TThreadId;
		end;
	TFileMetaData = record
			fileName, fileOwner, fileGroup: String;
			fileCanReadOwner, fileCanWriteOwner, fileCanExecuteOwner,
			fileCanReadGroup, fileCabWriteGroup, fileCanExecuteGroup,
			fileCanReadOthers, fileCanWriteOthers, fileCanExecuteOthers: Boolean;
		end;

implementation

begin
end.

