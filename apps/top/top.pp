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
	top;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	slibp;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	i, qlength, j: Longint;
	info: TProcessInfo;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*here we get the length of processes queue and process each item*)
	qlength := GetKernelInfo.osProcessQueueLength;
	for i := 0 to qlength do
		begin
			(*getting info*)
			info := KernelGetProcessInfo(i);
			(*outputting*)
			if not (info.pState = tps_none) then
				TextOutLn('"' +
					info.pName +
					'" [pid=' + IntToStr(i) +
					', tid=' + IntToStr(info.pTID) +
					', d=' + IntToStr(info.pDisplay) +
					', pri=' + IntToStr(KernelGetProcessPriority(i)) +
					', u=' + GetUserByUID(info.pUser) +
					', p=' + IntToStr(info.pParent) +
					', t=' + FormatDateTime('hh:nn:ss', now - info.pSTime) + ']');
			if Length(info.pChildren) > 1 then
				begin
					TextOut('Children: ');
					for j := 1 to Length(info.pChildren) - 1 do
						TextOut(IntToStr(info.pChildren[j]) + ' ');
					TextOutLn('');
		 		end;
		end;
	(*cleaning*)
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

