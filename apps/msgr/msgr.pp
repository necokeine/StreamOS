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
	msgr;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

var
	outstring: String;
	x, xm: WideString;

procedure messagehandler(message: TMessage);
var
	args:tpointers;
begin
	(*getting a string message*)
	if message.messageType = tmt_widestring then
		begin
			SetLength(args, 2);
			args[1] := nil;
			pointer(x) := message.message;
			outstring := '"' + x + '" f [pid=' + IntToStr(message.messageSender) + '] ';
			(*outputting it*)
			TextOut(outstring);
			(*calling sender process' export*)
			TextOut('[e] ');
			CallExport(message.messageSender, 1, args);
			TextOutLn('[/e]; ');
			xm := 'pong';
			SendMessage(message.messageSender, pointer(xm), tmt_widestring);
		end;
end;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
begin
	(*getting system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*setting self process name to identify*)
	SetProcessName('msgr');
	(*registering at free display*)
	RegisterDisplay(GetParentDisplay);
	(*falling sleep*)
	repeat
		Stay(getkernelinfo.osInternalTimerInterval);
	until false;
end;

procedure keyhandler(trancode: Char);
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

