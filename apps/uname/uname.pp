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
	uname;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	k, prmCount: Longint;
	kInfo: TKernelInfo;
	x, curPar: String;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*getting system info*)
	kInfo := GetKernelInfo;
	(*getting parameters count*)
	prmCount := GetParametersCount;
	if prmCount > 0 then
		begin
			x := '';
			for k := 1 to prmCount do
				begin
					(*there we receive parameters and add to output variable all the info*)
					curPar := GetParameter(k);
					if (curPar = '-a') or
						(curPar = '--all') then
						x += 	kInfo.osName + ' ' +
								kInfo.osHostname + ' ' +
								kInfo.osVersion + ' ' + '"' +
								kinfo.osCodeName + '" ';
					if (curPar = '-s') or
						(curPar = '--kernel-name') then
						x += kInfo.osName + ' ';
					if (curPar = '-r') or
						(curPar = '--release') then
						x += kInfo.osVersion+' ';
					if (curPar = '-c') or
						(curPar = '--codename') then
						x += '"' + kInfo.osCodeName + '" ';
					if (curPar = '-t') or
						(curPar = '--timer') then
						x += IntToStr(Round(1000 / kInfo.osInternalTimerInterval)) + ' Hz ';
					if (curPar = '-o') or
						(curPar = '--root') then
						x += 'ROOT=' + kInfo.osRoot + ' ';
					if (curPar = '-h') or
						(curPar = '--hostname') then
						x += kInfo.osHostname + ' ';
					if (curPar = '-l') or
						(curPar = '--lock') then
						x += 	'i:' + IntToStr(kInfo.osLockInit) +
								', e:' + IntToStr(kInfo.osLockEnter) +
								', l:' + IntToStr(kInfo.osLockLeave) +
								', d:' + IntToStr(kInfo.osLockDone) +
								', w:' + IntToStr(kInfo.osLockWait) +
								', a:' + IntToStr(kInfo.osLockAsk) + '';
				end;
			TextOutLn(x);
		end
	else
		begin
			(*if no parameters, we outputs only kernel name*)
			x := kInfo.osName;
			TextOutLn(x);
		end;
	(*unregistering the display*)
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

