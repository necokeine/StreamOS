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

(*===this library provides working with many independent virtual screens as if
they are real===*)
library
	displays;

uses
	sharedmem,
	crt,
	sysutils,
	stypes,
	lock;

type
	TDisplay = record
		data: TDisplayLines; (*stores text lines*)
		line, owners: Longint; (*count of lines and display owners*)
		localLocker: TLockContainer; (*virtual screen locker*)
	end;

var
	display: array of TDisplay; (*generally, displays :)*)
	dpr: array of Boolean; (*indicates which of displays are present*)
	currentDisplay: Longint; (*current display number*)
	consoleLocker, metaDataLocker: TLockContainer; (*lockings*)

(*===searches for empty display. If no displays are empty, a new display is
created===*)
function DisplayGetEmptyDisplay(a_null: Pointer): Longint;
var
	a: Longint;
begin
	(*cycle of searching*)
	a := 1;
	repeat
		if dpr[a] = false then
			break;
		inc(a);
	until a > Length(display) - 1;

	(*if no free displays, creates a new one*)
	if a > Length(display) - 1 then
		DisplayGetEmptyDisplay := length(display)
	else
		DisplayGetEmptyDisplay := a;
end;

(*===returns current display numbe===r*)
function DisplayGetCurrentDisplay(a_null: Pointer): Longint;
begin
	DisplayGetCurrentDisplay := currentDisplay;
end;

(*===shows given display===*)
procedure DisplayShowDisplay(i: Longint);
var
	a: Longint;
begin
	if (i < length(dpr)) and (*checking if the number is valid*)
		(dpr[i]) then
		begin
			(*sets the current display and clears the screen*)
			currentDisplay := i;
			EnterLock(consoleLocker);
			ClrScr;
			(*outputs the display to screen*)
			for a := 1 to display[i].line - 1 do
				WriteLn(display[i].data[a]);
			Write(display[i].data[display[i].line]);
			LeaveLock(consoleLocker);
		end;
end;

(*===creates a new display or adds an owner if the asked display is present===*)
procedure DisplayCreateDisplay(i: Longint);
var
	n: Longint;
begin
	EnterLock(metaDataLocker);
	(*make an array longer if needed*)
	if i > Length(dpr) - 1 then
		begin
			SetLength(dpr, i + 1);
			SetLength(display, i + 1);
		end;
	LeaveLock(metaDataLocker);
	(*if the display not exists, initialize it*)
	if not dpr[i] then
		begin
			InitLock(display[i].localLocker);
			EnterLock(display[i].localLocker);
			display[i].line := 1;
			for n := 1 to maxy do
				display[i].data[n] := '';
			display[i].owners := 0;
			LeaveLock(display[i].localLocker);
			dpr[i] := true;
		end;
	(*increasing owners count, the display cannot have zero owners*)
	EnterLock(display[i].localLocker);
	display[i].owners += 1;
	LeaveLock(display[i].localLocker);
end;

(*===destroys a display or decreases the number of owners===*)
procedure DisplayDestroyDisplay(i: Longint);
begin
	(*if it exists, decrease owners count*)
	if dpr[i] then
		display[i].owners -= 1;
	(*if it has zero owners, destroys it*)
	if (dpr[i]) and
		(display[i].owners = 0 ) and
		(i > 0) then
		begin
			EnterLock(metaDataLocker);
			dpr[i] := false;
			DoneLock(display[i].localLocker);
			(*decrease array length if needed*)
			if i = Length(dpr) - 1 then
				begin
					SetLength(dpr, i);
					SetLength(display, i);
				end;
			LeaveLock(metaDataLocker);
			(*if it was active, swith to zero display which always exists*)
			if currentDisplay = i then
				DisplayShowDisplay(0);
		end;
end;

(*===shifts the strings when its count more than maxy constant===*)
procedure DisplayShiftDisplay(i: Longint);
var
	n, x, y: Longint;
begin
	if (i < Length(dpr)) and (*if it exists...*)
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			(*shifts the lines in the buffer*)
			for n := 1 to maxy-1 do
				display[i].data[n] := display[i].data[n+1];
			(*clears the last line and make it active*)
			display[i].data[maxy]:='';
			display[i].line:=maxy;
			LeaveLock(display[i].localLocker);
			(*shifts the real screen if it's active*)
			if (display[i].line > maxy) and
				(i = currentDisplay) then
				begin
					EnterLock(consoleLocker);
					x := WhereX;
					y := WhereY;
					GotoXY(x, y);
					DelLine;
					GotoXY(x, y - 1);
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===clears the display===*)
procedure DisplayClearDisplay(i: Longint);
var
	a: Longint;
begin
	if (i < Length(dpr)) and (*if it exists...*)
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			(*fills display's data with empty strings*)
			for a := 1 to maxy do
				display[i].data[a] := '';
			(*sets the current line to first*)
			display[i].line := 1;
			LeaveLock(display[i].localLocker);
			(*if it's active display, shows the modifications*)
			if i = currentDisplay then
				begin
					(*waiting until the screen is not locked by another Write/WriteLn
					operator*)
					EnterLock(consoleLocker);
					(*clears the screen*)
					ClrScr;
					(*unlocks the screen*)
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===switches to the next display===*)
procedure DisplaySwitchDisplay;
begin
	EnterLock(metaDataLocker);
	(*finds the next display to switch to*)
	repeat
		currentDisplay += 1;
		if currentDisplay > Length(dpr) - 1 then
			currentDisplay := 0;
	until dpr[currentDisplay];
	LeaveLock(metaDataLocker);
	(*shows the display*)
	DisplayShowDisplay(currentDisplay);
end;

(*===shows the text on the display===*)
procedure DisplayTextOut(txt: String; i: Longint);
begin
	if (i < Length(dpr)) and
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			display[i].data[display[i].line] += txt;
			LeaveLock(display[i].localLocker);
			if i = currentDisplay then
				begin
					EnterLock(consoleLocker);
					Write(txt);
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===shows the text on the display with a new line===*)
procedure DisplayTextOutLn(txt: String; i: Longint);
begin
	if (i < length(dpr)) and
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			display[i].data[display[i].line] += txt;
			display[i].line += 1;
			LeaveLock(display[i].localLocker);
			if display[i].line > maxy then
				DisplayShiftDisplay(i);

			if i = currentDisplay then
				begin
					EnterLock(consoleLocker);
					WriteLn(txt);
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===shows parsed text line on the display===*)
procedure DisplayTextOutParse(txt: String; i: Longint);
var
	n: Longint;
	tmp: String;
begin
	n := 1;
	tmp := '';

	repeat
		if txt[n] = #10 then
			begin
				DisplayTextOutLn(tmp, i);
				tmp := '';
			end
		else
			tmp += txt[n];
		inc(n);
	until n > Length(txt);

	DisplayTextOut(tmp, i);
end;

(*===shows the text on the display with coordinates x and y===*)
procedure DisplayTextOutXy(txt: String; i, x, y: Longint);
var
	a, x1, y1: Longint;
begin
	if (i < Length(dpr)) and
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			for a := x to x + Length(txt) do
				display[i].data[y][a] := txt[a-x];
			display[i].line:=y;
			LeaveLock(display[i].localLocker);

			if i = currentDisplay then
				begin
					EnterLock(consoleLocker);
					x1 := WhereX;
					y1 := WhereY;
					GotoXY(x+1, y+1);
					Write(txt);
					GotoXY(x1, y1);
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===deletes the last line===*)
procedure DisplayDeleteLastLine(i: Longint);
begin
	if (i < Length(dpr)) and
		(dpr[i]) and
		(display[i].line > 0) then
		begin
			EnterLock(display[i].localLocker);
			display[i].data[display[i].line-1] := '';
			display[i].line -= 1;
			if display[i].line < 0 then
				display[i].line := 0;
			LeaveLock(display[i].localLocker);

			if (i = currentDisplay) then
				begin
					EnterLock(consoleLocker);
					GotoXY(wherex,wherey-1);
					DelLine;
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===deletes the last symbol===*)
procedure DisplayDeleteLastSymbol(i: Longint);
begin
	if (i < length(dpr)) and
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			SetLength(display[i].data[display[i].line], Length(display[i].data[display[i].line]) - 1);
			LeaveLock(display[i].localLocker);

			if i = currentDisplay then
				begin
					EnterLock(consoleLocker);
					GotoXY(WhereX-1, WhereY);
					Write(' ');
					GotoXY(wherex-1, WhereY);
					LeaveLock(consoleLocker);
				end;
		end;
end;

(*===assigns the whole buffer to a virtual display. It might be used by text
editors or something like this to output the whole screen not line-by-line===*)
procedure DisplayAssignBuffer(i: Longint; buffer: TDisplayLines);
begin
	if (i < Length(dpr)) and
		(dpr[i]) then
		begin
			EnterLock(display[i].localLocker);
			display[i].data := buffer;
			display[i].line := 25;
			LeaveLock(display[i].localLocker);
			if i = currentDisplay then
				DisplayShowDisplay(i);
		end;
end;

exports

DisplayGetEmptyDisplay		name 'DisplayGetEmptyDisplay',
DisplayGetCurrentDisplay	name 'DisplayGetCurrentDisplay',
DisplayShowDisplay			name 'DisplayShowDisplay',
DisplayCreateDisplay			name 'DisplayCreateDisplay',
DisplayDestroyDisplay		name 'DisplayDestroyDisplay',
DisplayClearDisplay			name 'DisplayClearDisplay',
DisplaySwitchDisplay			name 'DisplaySwitchDisplay',
DisplayTextOut					name 'DisplayTextOut',
DisplayTextOutLn				name 'DisplayTextOutLn',
DisplayTextOutParse			name 'DisplayTextOutParse',
DisplayTextOutXy				name 'DisplayTextOutXy',
DisplayDeleteLastLine		name 'DisplayDeleteLastLine',
DisplayDeleteLastSymbol		name 'DisplayDeleteLastSymbol',
DisplayAssignBuffer			name 'DisplayAssignBuffer';

begin
	lock.InitLock(consoleLocker);
	lock.InitLock(metaDataLocker);
end.

