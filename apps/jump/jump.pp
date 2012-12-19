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
	jump;

uses
	sharedmem,
	stypes,
	sysutils,
	imports,
	tools;

var
	x, y, xs, ys: Longint;
	quit: Boolean;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccessKey);export;
begin
	quit := false;
	(*getting system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parents display and clean it*)
	RegisterDisplay(GetParentDisplay);
	ClearDisplay;
	(*init*)
	x := 0;
	y := 0;
	xs := 1;
	ys := 1;
	repeat
		(*deletes previous symbol*)
		TextOutXY(x, y, ' ');
		(*next symbol position*)
		x := x + xs;
		y := y + ys;
		(*reflections from borders*)
		if x > 79 then
			begin
				xs := -1;
				x := x + xs;
			end
				else
		if x < 1 then
			begin
				xs := 1;
				x := x + xs;
			end;
		if y > 24 then
			begin
				ys := -1;
				y := y + ys;
			end
				else
		if y < 1 then
			begin
				ys := 1;
				y := y + ys;
			end;
		(*shows symbol*)
		TextOutXY(x, y, '*');
		(*some delay*)
		Stay(10);
	until quit;
	ClearDisplay;
	UnRegisterDisplay;
end;

procedure keyhandler(trancode: Char);
begin
	if trancode = #27 then
		quit := true;
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

