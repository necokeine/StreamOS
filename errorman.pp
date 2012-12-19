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

unit
	errorman;

interface

procedure ErrormanRaiseKernelFatal(code: Longint);
procedure ErrormanRaiseKernelError(code: Longint; message: String);

implementation

uses
	debug;

{$i config.inc}

procedure ErrormanRaiseKernelFatal(code: Longint);
begin
	(*this procedure is used to do something if the kernel gets a fatal error*)
	(*0 - kernel panic during init start*)
	case code of
		0: begin
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, init panic');
				{$else}
					debug.DebugMark('Kernel, init panic');
				{$endif}
				(*it's useless to continue working, so kernel halts*)
				Halt(0);
			end;
		end;
end;

procedure ErrormanRaiseKernelError(code: Longint; message: String);
begin
	(*
		if a kernel gets non-fatal error, this procedure can do something, in
		general, it just reports the user about an accident

		0 - process creation error
		1 - process destroying error
		2 - process execution error
	*)
	case code of
		0: begin
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, process creation error');
				{$endif}
			end;
		1: begin
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, process destroying error');
				{$endif}
			end;
		2: begin
				{$ifdef config_debug}
					debug.DebugReportEvent('Kernel, process executing error');
				{$endif}
			end;
		end;
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, ' + message);
	{$endif}
end;

begin
end.

