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
	modules;

(*loads kernel modules*)

interface

uses
	stypes;

procedure LoadKernelModules;

var
	displayLoaded: Boolean;

function  DisplayGetEmptyDisplay: Longint;
function  DisplayGetCurrentDisplay: Longint;
procedure DisplayShowDisplay(i: Longint);
procedure DisplayCreateDisplay(i: Longint);
procedure DisplayDestroyDisplay(i: Longint);
procedure DisplayShiftDisplay(i: Longint);
procedure DisplayClearDisplay(i: Longint);
procedure DisplaySwitchDisplay;
procedure DisplayTextOut(txt: String; i: Longint);
procedure DisplayTextOutLn(txt: String; i: Longint);
procedure DisplayTextOutParse(txt: String; i: Longint);
procedure DisplayTextOutXy(txt: String; i, x, y: Longint);
procedure DisplayDeleteLastLine(i: Longint);
procedure DisplayDeleteLastSymbol(i: Longint);
procedure DisplayAssignBuffer(i: Longint; buffer: TDisplayLines);

implementation

uses
	dynlibs,
	fs,
	inifiles,
	sysutils;

var
	_DisplayGetEmptyDisplay:   function(a_null: Pointer): Longint;
	_DisplayGetCurrentDisplay: function(a_null: Pointer): Longint;
	_DisplayShowDisplay:       procedure(i: Longint);
	_DisplayCreateDisplay:     procedure(i: Longint);
	_DisplayDestroyDisplay:    procedure(i: Longint);
	_DisplayShiftDisplay:      procedure(i: Longint);
	_DisplayClearDisplay:      procedure(i: Longint);
	_DisplaySwitchDisplay:     procedure;
	_DisplayTextOut:           procedure(txt: String; i: Longint);
	_DisplayTextOutLn:         procedure(txt: String; i: Longint);
	_DisplayTextOutParse:      procedure(txt: String; i: Longint);
	_DisplayTextOutXy:         procedure(txt: String; i, x, y: Longint);
	_DisplayDeleteLastLine:    procedure(i: Longint);
	_DisplayDeleteLastSymbol:  procedure(i: Longint);
	_DisplayAssignBuffer:      procedure(i: Longint; buffer: TDisplayLines);


function DisplayGetEmptyDisplay: Longint;
begin
	if displayLoaded then
		DisplayGetEmptyDisplay := _DisplayGetEmptyDisplay(nil);
end;

function DisplayGetCurrentDisplay: Longint;
begin
	if displayLoaded then
		DisplayGetCurrentDisplay := _DisplayGetCurrentDisplay(nil);
end;

procedure DisplayShowDisplay(i: Longint);
begin
	if displayLoaded then
		_DisplayShowDisplay(i);
end;

procedure DisplayCreateDisplay(i: Longint);
begin
	if displayLoaded then
		_DisplayCreateDisplay(i);
end;

procedure DisplayDestroyDisplay(i: Longint);
begin
	if displayLoaded then
		_DisplayDestroyDisplay(i);
end;

procedure DisplayShiftDisplay(i: Longint);
begin
	if displayLoaded then
		_DisplayShiftDisplay(i);
end;

procedure DisplayClearDisplay(i: Longint);
begin
	if displayLoaded then
		_DisplayClearDisplay(i);
end;

procedure DisplaySwitchDisplay;
begin
	if displayLoaded then
		_DisplaySwitchDisplay;
end;

procedure DisplayTextOut(txt: String; i: Longint);
begin
	if displayLoaded then
		_DisplayTextOut(txt, i);
end;

procedure DisplayTextOutLn(txt: String; i: Longint);
begin
	if displayLoaded then
		_DisplayTextOutLn(txt, i);
end;

procedure DisplayTextOutParse(txt: String; i: Longint);
begin
	if displayLoaded then
		_DisplayTextOutParse(txt, i);
end;

procedure DisplayTextOutXy(txt: String; i, x, y: Longint);
begin
	if displayLoaded then
		_DisplayTextOutXy(txt, i, x, y);
end;

procedure DisplayDeleteLastLine(i: Longint);
begin
	if displayLoaded then
		_DisplayDeleteLastLine(i);
end;

procedure DisplayDeleteLastSymbol(i: Longint);
begin
	if displayLoaded then
		_DisplayDeleteLastSymbol(i);
end;

procedure DisplayAssignBuffer(i: Longint; buffer: TDisplayLines);
begin
	if displayLoaded then
		_DisplayAssignBuffer(i, buffer);
end;


procedure LoadKernelModules;
var
	displaysLibrary: TLibHandle;
	f: TIniFile;
	i, count: Longint;
	modType, modFile: String;
begin
	(*read modules list from special file*)
	f := TIniFIle.Create(fs.StreamFSToDOS('/etc/modules.dep'));
	count := f.ReadInteger('common', 'count', 0);
	if(not (count = 0)) then
		begin
			for i := 1 to count do
				begin
					modType := f.ReadString('module_' + IntToStr(i), 'type', 'none');
					modFile := f.ReadString('module_' + IntToStr(i), 'file', 'none');
					if((modType = '') or
						(modFile = '')) then
						continue;
					(*process different module types*)
					if(modType = 'console') then
						begin
							displaysLibrary := LoadLibrary(modFile);
							pointer(_DisplayGetEmptyDisplay)   :=GetProcedureAddress(displaysLibrary, 'DisplayGetEmptyDisplay');
							pointer(_DisplayGetCurrentDisplay) :=GetProcedureAddress(displaysLibrary, 'DisplayGetCurrentDisplay');
							pointer(_DisplayShowDisplay)       :=GetProcedureAddress(displaysLibrary, 'DisplayShowDisplay');
							pointer(_DisplayCreateDisplay)     :=GetProcedureAddress(displaysLibrary, 'DisplayCreateDisplay');
							pointer(_DisplayDestroyDisplay)    :=GetProcedureAddress(displaysLibrary, 'DisplayDestroyDisplay');
							pointer(_DisplayShiftDisplay)      :=GetProcedureAddress(displaysLibrary, 'DisplayShiftDisplay');
							pointer(_DisplayClearDisplay)      :=GetProcedureAddress(displaysLibrary, 'DisplayClearDisplay');
							pointer(_DisplaySwitchDisplay)     :=GetProcedureAddress(displaysLibrary, 'DisplaySwitchDisplay');
							pointer(_DisplayTextOut)           :=GetProcedureAddress(displaysLibrary, 'DisplayTextOut');
							pointer(_DisplayTextOutLn)         :=GetProcedureAddress(displaysLibrary, 'DisplayTextOutLn');
							pointer(_DisplayTextOutParse)      :=GetProcedureAddress(displaysLibrary, 'DisplayTextOutParse');
							pointer(_DisplayTextOutXy)         :=GetProcedureAddress(displaysLibrary, 'DisplayTextOutXy');
							pointer(_DisplayDeleteLastLine)    :=GetProcedureAddress(displaysLibrary, 'DisplayDeleteLastLine');
							pointer(_DisplayDeleteLastSymbol)  :=GetprocedureAddress(displaysLibrary, 'DisplayDeleteLastSymbol');
							pointer(_DisplayAssignBuffer)      :=GetprocedureAddress(displaysLibrary, 'DisplayAssignBuffer');
							displayLoaded := true;
							DisplayCreateDisplay(0);
							DisplayClearDisplay(0);
							DisplayShowDisplay(0);
						end;
				end;
		end;
	f.Free;
end;

begin
	displayLoaded := false;
end.

