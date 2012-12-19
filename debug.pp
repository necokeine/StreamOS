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
	debug;

interface

uses
	stypes;

procedure DebugReportEvent(message: String);
procedure DebugMark(message: String);

var
	debugToFile: Boolean;
	debugLock: TLockContainer;

implementation

uses
	sysutils,
	modules,
	fs,
	kernel,
	lock;

(*===reports debug event to debug stream (virtual system console or file)===*)
procedure DebugReportEvent(message: String);
var
	logf: TextFile;
begin
	EnterLock(debugLock);
	(*it displays debug messages from kernel (pid=0) with timestamps*)
	if debugToFile then
		begin
			Assign(logf, fs.StreamFSToDOS('/var/log/kern.log'));
			Append(logf);
			WriteLn(logf, FormatDateTime('mmm d hh:nn:ss', now) + ' ' + kernel.kernelHostname + ': ' + message);
			Close(logf);
		end
	else
		DisplayTextOutLn(FormatDateTime('mmm d hh:nn:ss', now) + ' ' + kernel.kernelHostname + ': ' + message, 0);
	LeaveLock(debugLock);
end;

(*===shows kernel mark directly to the physical console===*)
procedure DebugMark(message: String);
begin
	WriteLn('Kernel mark: ' + message);
end;

begin
end.

