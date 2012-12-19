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
	tools;

interface

uses
	stypes;

function  ToolsSplitLine(str: String; ch: Char): TDynamicStringList;
function  ToolsGenerateAccessKey: TAccessKey;
function  ToolsCompareAccessKeys(key1, key2: TAccessKey): Boolean;
procedure Stay(msecs: Longint);

implementation

uses
	sysutils;

function ToolsSplitLine(str: String; ch: Char): TDynamicStringList;
var
	i, cnt: Longint;
	str_out: TDynamicStringList;
	tmp: String;
begin
	(*initializing*)
	cnt := 1;
	tmp := str;
	SetLength(str_out, 0);
	(*searching split char and splitting the string*)
	repeat
		i := Pos(ch, tmp);
		if i > 0 then
			begin
				SetLength(str_out, cnt + 1);
				str_out[cnt] := Copy(tmp, 1, i - 1);
				inc(cnt);
				Delete(tmp, 1, i);
			end;
	until i = 0;
	(*putting the last part*)
	SetLength(str_out, cnt + 1);
	str_out[cnt] := tmp;
	(*setting the result*)
	SetLength(ToolsSplitLine, Length(str_out));
	ToolsSplitLine := str_out;
end;

function ToolsGenerateAccessKey: TAccessKey;
var
	tmp: TAccessKey;
	i: Longint;
begin
	Randomize;
	for i := 1 to accessKeyLength do
		tmp[i] := Random(256);
	ToolsGenerateAccessKey := tmp;
end;

function ToolsCompareAccessKeys(key1, key2: TAccessKey): Boolean;
var
	h: Boolean;
	i: Longint;
begin
	h := true;
	for i := 1 to accessKeyLength do
		if not (key1[i] = key2[i]) then
			begin
				h := false;
				break;
			end;
	ToolsCompareAccessKeys := h;
end;

procedure Stay(msecs: Longint);
begin
	Sleep(msecs);
end;

end.

