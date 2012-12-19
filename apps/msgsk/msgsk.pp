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
	msgsk;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

var
	x: WideString;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
begin
	(*getting system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*init*)
	RegisterDisplay(GetParentDisplay);
	repeat
		x := 'ping';
		SendMessage(0, pointer(x), tmt_widestring);
		Stay(500);
	until false;
end;

procedure keyhandler(trancode: Char);
begin
end;

procedure messagehandler(message: TMessage);
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

