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
	kill;

uses
	sharedmem,
	stypes,
	sysutils,
	imports;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
var
	prmcount, i, sig: Longint;
	x: String;
	pinfo: TProcessInfo;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	RegisterDisplay(GetParentDisplay);
	(*getting parameters*)
	prmcount := GetParametersCount;
	if prmcount > 1 then
		begin
			sig := StrToInt(GetParameter(1));
			if (sig < 0) or
				(sig > 31) then
				begin
					TextOutLn('Wrong signal specified');
				end
					else
				begin
					x := GetParameter(2);
					if x = 'all' then
						begin
							(*sending the signal to all tasks*)
							for i := 1 to GetKernelInfo.osProcessQueueLength do
								begin
									pinfo := KernelGetProcessInfo(i);
									if (not (i = pid)) and
										(not (pinfo.pName = '')) and
										(not (pinfo.pState = tps_none)) and
										(not (pinfo.pState = tps_creating)) and
										(not (pinfo.pState = tps_destroying)) then
										SendSignal(i, sig);
	    						end
          			end
            	else
          			(*sends the signal to specified process*)
          			if not SendSignal(StrToInt(x), sig) then
             			TextOutLn('Can''t send a signal to process!');
				end;
		end
			else
		begin
			if GetParametersCount = 1 then
				begin
					if GetParameter(1) = '--version' then
						begin
							TextOutLn('kill - send signal');
							TextOutLn('StreamUtils ' + GetKernelInfo.osVersion);
							TextOutLn('(C) Oleksandr Natalenko aka post-factum');
						end
							else
					if (GetParameter(1) = '-h') or
						(GetParameter(1) = '--help') then
						begin
							TextOutLn('Usage: kill <signal> <PID>');
							TextOutLn('or: kill [--version|--help>|-h]');
						end
					else
						TextOutLn('Wrong parameter specified');
				end
			else
				TextOutLn('No parameters specified')
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
end;

exports

main name 'lib_main',
keyhandler name 'lib_key',
messagehandler name 'lib_msg',
signalhandler name 'lib_signal';

begin
end.

