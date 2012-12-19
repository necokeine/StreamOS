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
	slibp;

interface

function GetUserByUID(uid: Longint): String;

implementation

uses
	inifiles,
	imports,
	sysutils;

function GetUserByUID(uid: Longint): String;
var
	f: TIniFile;
	k, count, uuid: Longint;
	uname: String;
begin
	f := TIniFile.Create(FsGetDosPath('/etc/shadow'));
	count := f.ReadInteger('common', 'count', 0);
	for k := 1 to count do
		begin
			uuid := f.ReadInteger('user_' + IntToStr(k), 'uid', 0);
			if uuid = uid then
				begin
					uname := f.ReadString('user_' + IntToStr(k), 'login', '');
					break;
				end;
		end;
	f.Free;
	GetUserByUID := uname;
end;

end.

