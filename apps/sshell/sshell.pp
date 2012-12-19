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
	sshell;

uses
	sharedmem,
	stypes,
	tools,
	sysutils,
	imports,
	slibp;

const
	version = '0.4.7';

var
	quit, shouldWait, canPrint: Boolean;
	command, tmp, tmp2, tmp4: String;
	uSymbol: Char;
	myDisplay, k, rpid, i, tmp3, lastDir, myPid: Longint;
	myInfo, info: TProcessInfo;
	cmdLine, params: TDynamicStringList;

procedure show_banner;
begin
	textoutln('SCULL Shell v' + version + ' on [display=' + IntToStr(myDisplay) + ']');
	textoutln('(C) Oleksandr Pundyk aka Nobody, 2004-2009');
	textoutln('(C) Oleksandr Natalenko aka post-factum, 2004-2009');
end;

procedure dowork;
begin
	(*getting command line*)
	cmdline := tools.ToolsSplitLine(command, #32);
	if cmdline[1] = '' then
		begin
		end
			else
	if cmdline[1] = 'help' then
		begin
			(*showing help*)
			textoutln('');
			show_banner;
			textoutln('');
			textoutln('help - this help');
			textoutln('logout - quit from shell and start login again');
			textoutln('cd - changing the current directory');
			textoutln('');
			textoutln('To switch between virtual displays use CTRL+q combination');
		end
			else
	if cmdline[1] = 'cd' then
		begin
			if cmdline[2] = '..' then
				begin
					(*getting current directory and cutting the last / symbol if any*)
					tmp := GetCurrentDirectory;
					if not (tmp = '/') then
						begin
							if tmp[Length(tmp)] = '/' then
								tmp[Length(tmp)] := #0;
							(*reversing the string*)
							tmp2 := tmp;
							for i := 1 to Length(tmp) do
								tmp2[i] := tmp[Length(tmp) - i + 1];
							(*finding the last / symbol and cutting the path to get parent directory*)
							tmp3 := Pos('/', tmp2);
							lastdir := Length(tmp2) - tmp3 + 1;
							tmp4 := Copy(tmp, 1, lastdir);
							(*setting the current directory, it'll be parent directory*)
							SetCurrentDirectory(tmp4);
						end;
				end
					else
			if cmdline[2] = '.' then
				begin
					(*just do nothing because it's current directory*)
				end
					else
			begin
				(*detecting the last / symbol to prevent being // in the path*)
				tmp := GetCurrentDirectory;
				if tmp[Length(tmp)] = '/' then
					tmp2 := tmp + cmdline[2]
				else
					tmp2 := tmp + '/' + cmdline[2];
				(*and setting the directory*)
				if FsFileExists(tmp2, tft_directory) then
					SetCurrentDirectory(tmp2)
				else
					TextOutLn('No such directory: ' + tmp2);
			end;
		end
			else
	if cmdline[1] = 'logout' then
		(*exiting*)
		quit := true
			else
	begin
		(*parsing the command line and executing the process*)
		if cmdline[Length(cmdline) - 1] = '&' then
			begin
				(*sending process to background*)
				shouldwait := false;
				SetLength(cmdline, Length(cmdline) - 1);
			end;
		SetLength(params, Length(cmdline) - 1);
		(*getting parameters*)
		for k := 2 to Length(cmdline) - 1 do
			params[k - 1] := cmdline[k];
		rpid := ProcessCreate(cmdline[1], params, mypid, myinfo.pUser);
		if rpid = -1 then
			begin
				(*error*)
				textoutln('');
				textoutln('Unable to execute: ' + cmdline[1]);
			end
				else
		begin
			if shouldwait then
				begin
					canprint := false;
					info := KernelGetProcessInfo(rpid);
					WaitForThreadTerminate(info.pTID, 0);
					canprint := true;
				end;
			shouldwait:=true;
		end;
	end;
	if not quit then
		begin
			command := '';
			TextOutLn('');
			TextOut(GetUserByUID(myinfo.pUser) + '@' + GetKernelInfo.osHostname + ':' + GetCurrentDirectory + usymbol + ' ');
		end;
end;

procedure keyhandler(trancode: Char);
begin
	if canprint then
		begin
			(*if ENTER*)
			if trancode = #13 then
				(*executes a command*)
				dowork
					else
			(*if BACKSPACE*)
			if trancode = #8 then
				begin
					if Length(command) > 0 then
						begin
							(*it deletes a symbol from buffer and screen*)
							SetLength(command, Length(command) - 1);
							DeleteLastSymbol;
						end;
				end
					else
			begin
				(*if another key, just add it to buffer*)
				command += trancode;
				TextOut(trancode);
			end;
		end;
end;

procedure main(pid: Longint; systemCallsTable: TSystemCalls; accesskey: TAccessKey); export;
begin
	(*init*)
	quit :=false;
	shouldwait := true;
	canprint := true;
	command := '';
	(*importing system calls*)
	ImportsImportSystemCalls(systemCallsTable, pid, accessKey);
	(*registering at parent display*)
	mypid := pid;
	myinfo := GetProcessInfo;
	if myinfo.pUser = 0 then
		usymbol := '#'
	else
		usymbol := '$';
	mydisplay := GetParentDisplay;
	RegisterDisplay(mydisplay);
	(*welcome message*)
	show_banner;
	TextOut(GetUserByUID(myinfo.pUser) + '@' + GetKernelInfo.osHostname + ':' + GetCurrentDirectory + usymbol + ' ');
	repeat
		Stay(GetKernelInfo.osInternalTimerInterval);
	until quit;
	(*after exiting...*)
	UnregisterDisplay;
end;

procedure messagehandler(message: TMessage);
begin
end;

procedure signalhandler(signal,sender: Longint);
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

