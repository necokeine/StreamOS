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
	ls;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	info: TSearchRec;
	spath, outstring: String;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*getting parameters*)
	if GetParametersCount > 0 then
		spath := GetParameter(1)
	else
		spath := GetCurrentDirectory;
	if spath[Length(spath)] = '/' then
		spath += '*'
	else
		spath += '/*';
	(*finding files*)
	if FindFirst(FsGetDosPath(spath), FAAnyFile and FADirectory, info) = 0 then
		begin
			repeat
				outstring := info.name;
				TextOutLn(outstring);
			until not (FindNext(info) = 0);
		end;
	(*cleaning*)
	FindClose(info);
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

