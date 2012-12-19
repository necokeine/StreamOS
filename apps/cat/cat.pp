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
	cat;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey); export;
var
	f: TextFile;
	s: String;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemcallstable, pid, accesskey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*getting parameters*)
	if GetParametersCount < 1 then
		begin
			TextOutLn('No file specified');
		end
			else
	if GetParameter(1) = '--version' then
		begin
			TextOutLn('cat - show file content');
			TextOutLn('StreamUtils ' + GetKernelInfo.osVersion);
			TextOutLn('(C) Oleksandr Natalenko aka post-factum');
		end
			else
	if (GetParameter(1) = '-h') or
		(GetParameter(1) = '--help') then
		begin
			TextOutLn('Usage: cat <filename>');
			TextOutLn('or: cat [--version|--help>|-h]');
		end
			else
		begin
			Assign(f, FsGetDosPath(GetParameter(1)));
			Reset(f);
			while not EOF(f) do
				begin
					readln(f, s);
					TextOutLn(s);
				end;
         Close(f);
         end;
  (*cleaning...*)
  UnregisterDisplay;
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

