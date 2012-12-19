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
	suspend;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

procedure main(pid: Longint; systemCallstable: TSystemCalls; accessKey: TAccessKey);export;
var
	f: String;
	res: Longint;
begin
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	RegisterDisplay(GetParentDisplay);
	TextOutLn('Preparing suspend...');
	f := FileSearch('suspend.exe', GetEnvironmentVariable('PATH'));
	res := ExecuteProcess(f, '');
	if res = 1 then
		TextOutLn('You need APM v1.1 or greater to suspend')
			else
	if res = 2 then
		TextOutLn('You need APM v1.1 or greater to be present')
			else
		TextOutLn('Waking up...');
	UnRegisterDisplay;
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

