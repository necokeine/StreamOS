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
	ttest;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

var
	quit: Boolean;

procedure ThisTimer;
begin
	TextOutLn('Timer tick on ' + FormatDateTime('hh:nn:ss.zzz', now));
end;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	tid: Longint;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	RegisterDisplay(GetParentDisplay);
	tid := AddApplicationTimer(@ThisTimer, 1000, false);
	InvokeApplicationTimer(tid);
	(*starting benchmarking*)
	quit := false;
	repeat
		Stay(GetKernelInfo.osInternalTimerInterval);
	until quit;
	TextOutLn('Exiting...');
	RemoveApplicationTimer(tid);
	UnRegisterDisplay;
end;

procedure keyhandler(trancode: Char);
begin
	if trancode = #27 then
		quit:=true;
end;

procedure messagehandler(message: TMessage);
begin
end;

procedure signalhandler(signal, sender: Longint);
begin
	if signal = 15 then
		quit := true;
end;

exports

main name 'lib_main',
keyhandler name 'lib_key',
messagehandler name 'lib_msg',
signalhandler name 'lib_signal';

begin
end.

