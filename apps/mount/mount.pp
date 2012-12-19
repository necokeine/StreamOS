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
	mount;

uses
	sharedmem,
	stypes,
	sysutils,
	tools,
	imports,
	inifiles;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accessKey: TAccesskey); export;
var
    k, prmcount, i, count: Longint;
    ffstab : TIniFile;
    tmp : TFsTabRecord;
    kInfo : TKernelInfo;
begin
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	RegisterDisplay(GetParentDisplay);
	(*getting parameters count*)
	prmcount := GetParametersCount;
	if prmcount > 0 then
		begin
			for k := 1 to prmcount do
				begin
					if (GetParameter(k) = '-a') or
						(GetParameter(k) = '--all') then
						begin
							ffstab := TIniFIle.Create(FsGetDosPath('/etc/fstab'));
							count := ffstab.ReadInteger('common', 'count', 0);
							for i := 1 to count do
								begin
									with tmp do
										begin
											source := ffstab.ReadString('record_' + IntToStr(i), 'dev', '');
		  									mountpoint := ffstab.ReadString('record_' + IntToStr(i), 'mount', '');
		  									filesystem := ffstab.ReadString('record_' + IntToStr(i), 'fs', '');
		  									options := ffstab.ReadString('record_' + IntToStr(i), 'opts', '');
										end;
									FsAddFsTabRecord(tmp);
								end;
						end;
				end;
		end
			else
		begin
			kInfo := GetKernelInfo;
			for i := 1 to Length(kInfo.osFsTab) - 1 do
				TextOutLn(kInfo.osFsTab[i].source + ' ' + kInfo.osFsTab[i].mountpoint + ' ' + kInfo.osFsTab[i].filesystem + ' ' + kInfo.osFsTab[i].options);
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

