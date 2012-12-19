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
	bench;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

var
	quit: Boolean;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
    et: Extended;
    i: Longint;
    s: String;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	RegisterDisplay(GetParentDisplay);
	(*starting benchmarking*)
	quit := false;
	repeat
		i := 0;
		et := now + 1 / 86400; (*60 seconds * 60 minutes * 24 hours*)
		repeat
			Inc(i); (*marks count*)
		until now >= et; (*1 second*)
		s := 'You''ve got ' + IntToStr(i) + ' points';
		TextOutLn(s);
	until quit;
	TextOutLn('Exiting...');
	UnRegisterDisplay;
end;

procedure keyhandler(trancode: Char);
begin
	if trancode = #27 then
		quit := true;
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

