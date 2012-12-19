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
	sysctl;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	k, prmcount: Longint;
	params: TDynamicStringList;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering display*)
	RegisterDisplay(GetParentDisplay);
	(*getting parameters count*)
	prmcount := GetParametersCount;
	if prmcount > 0 then
		for k := 1 to prmcount do
			begin
				params := tools.ToolsSplitLine(GetParameter(k), '=');
				if (params[1] = 't') or
					(params[1] = 'timer') then
					if not SetInternalTimerInterval(Round(1000 / StrToInt(params[2]))) then
						TextOutLn('Only root can do that');
				if (params[1] = 'h') or
					(params[1] = 'hostname') then
					if not SetHostName(params[2]) then
						TextOutLn('Only root can do that');
			end;
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

