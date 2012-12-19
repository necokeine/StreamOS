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

program
	streamos;

(*main StreamOS file*)

uses
	sharedmem,
	kernel,
	errorman,
	init,
	managers,
	debug,
	sysutils;

{$i config.inc}

begin
	(*does internal initializing*)
	init.InitKernelVariables;
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, starting');
	{$endif}
	(*executes init with its parameters, if not - panics*)
	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, executing init');
	{$endif}
	if kernel.KernelProcessCreate(init.initName, init.initParams, 0, 0) = -1 then
		errorman.ErrormanRaiseKernelFatal(0);

	{$ifdef config_debug}
		debug.DebugReportEvent('Kernel, falling into infinite loop');
	{$endif}
	(*falling sleep*)
	WaitForThreadTerminate(BeginThread(@ManagersExecuteInternalKeyHandler, nil), 0);
end.

