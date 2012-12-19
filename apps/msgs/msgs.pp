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
	msgs;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

var
	rpid: Longint;
	x: WideString;
	p: TExports;

function export1(args: TPointers): TPointers;
var
	ret: TPointers;
begin
	SetLength(ret, 2);
	ret[0] := nil;
	ret[1] := nil;
	export1 := ret;
end;

procedure main(pid:longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
begin
	(*getting system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*init*)
	RegisterDisplay(GetParentDisplay);
	rpid := 0;
	(*exporting a function*)
	SetLength(p.te_pointers, 2);
	SetLength(p.te_names, 2);
	p.te_pointers[1] := @export1;
	p.te_names[1] := 'export1';
	RegisterExports(p);
	(*waiting for receiver to appear*)
	repeat
		Stay(1);
		rpid := FindProcess('msgr');
	until not (rpid = 0);
	(*sending messages*)
	repeat
		x := 'ping';
		SendMessage(rpid, pointer(x), tmt_widestring);
		Stay(500);
	until false;
end;

procedure keyhandler(trancode: Char);
begin
end;

procedure messagehandler(message: TMessage);
var
	r: WideString;
begin
	if message.messageType = tmt_widestring then
		begin
			pointer(r) := message.message;
			TextOutLn(r + ' f [pid=' + IntToStr(message.messageSender) + ', t=' + FormatDateTime('ss.zzz' + ']', now - message.messageId));
		end;
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

