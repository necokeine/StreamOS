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
	cp;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

var
	quit:boolean;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
const
	bufLen = 16384;
var
	fin, fout: File of Byte;
	buffer: array[1..bufLen] of Byte;
	numRead, numWritten, wrote: Longint;
	et: Extended;
	tmpParam: String;
begin
	quit := false;
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*getting parameters*)
	if GetParametersCount < 2 then
		begin
			if GetParametersCount = 1 then
				begin
					tmpParam := GetParameter(1);
					if tmpParam = '--version' then
						begin
							TextOutLn('cp - copy file');
							TextOutLn('StreamUtils ' + GetKernelInfo.osVersion);
							TextOutLn('(C) Oleksandr Natalenko aka post-factum');
						end
							else
					if (tmpParam = '-h') or
						(tmpParam = '--help') then
						begin
							TextOutLn('Usage: cp <source> <target>');
							TextOutLn('or: cp [--version|--help>|-h]');
						end
							else
						TextOutLn('Wrong parameter specified');
				end
			else
				TextOutLn('No files specified');
		end
			else
		begin
			(*opening files*)
			Assign(fin, FsGetDosPath(GetParameter(1)));
			Reset(fin);
			Assign(fout, FsGetDospath(GetParameter(2)));
			Rewrite(fout);
			wrote := 0;
			TextOutLn('');
			et := now + 1 / 86400; (*60*60*24*)
			repeat
				(*reading by blocks, size may be adjusted by buflen constant*)
				BlockRead(fin, buffer, bufLen, numRead);
				BlockWrite(fout, buffer, numRead, numWritten);
				Inc(wrote, numRead);
				if Now >= et then
					begin
						(*is executed every second, shows the speed of copying*)
						DeleteLastLine;
						TextOutLn('Copying ' + GetParameter(1) + ' to ' + GetParameter(2) + ' @ ' + IntToStr(wrote div 1024) + ' Kbps');
						wrote := 0;
						et := Now + 1 / 86400;
					end;
			until (numRead = 0) or
					(not (numRead = numWritten)) or
					(quit);
			(*closing files*)
			Close(fout);
			Close(fin);
		end;
	(*cleaning...*)
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

