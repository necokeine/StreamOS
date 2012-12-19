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
	fs;

(*the unit provides StreamFS implementation and some basic filesystem functions
  for StreamOS*)

interface

uses
	stypes;

{$i config.inc}

function FsAddToFsTab(_source, _mountpoint, _filesystem, _options: String): Boolean;
function FsCopyFile(source, target: String): Boolean;
function StreamFSToDOS(streamFsPath: String): String;
function FsFileExists(filePath: String; fileType: TFileType): Boolean;

var
	kernelFsTab: TFsTabRecords;

implementation

uses
	sysutils,
	kernel,
	tools,
	inifiles;

(*===add new fstab entry===*)
function FsAddToFsTab(_source, _mountpoint, _filesystem, _options: String): Boolean;
var
	k: Longint;
begin
	if (not (_source = '')) and
		(not (_mountpoint = '')) and
		(not (_filesystem = '')) and
		(not (_options = '')) then
		begin
			(*shifts the array*)
			SetLength(kernelFsTab, Length(kernelFsTab) + 1);
			for k := Length(kernelFsTab) - 1 downto 2 do
				begin
					kernelFsTab[k].source := kernelFsTab[k - 1].source;
					kernelFsTab[k].mountpoint := kernelFsTab[k - 1].mountpoint;
					kernelFsTab[k].filesystem := kernelFsTab[k - 1].filesystem;
					kernelFsTab[k].options := kernelFsTab[k - 1].options;
				end;
			(*add a new entry*)
			with kernelFsTab[1] do
				begin
					source := _source;
					mountpoint := _mountpoint;
					filesystem := _filesystem;
					options := _options;
				end;
			FsAddToFsTab := true;
		end
			else
		FsAddToFsTab := false;
end;

(*===kernel-level file copying===*)
function FsCopyFile(source, target: String): Boolean;
var
	fIn, fOut: File of Byte;
	buffer: array[1..fsBufferSize] of Byte;
	numRead, numWritten: Longint;
begin
	FsCopyFile := true;
	try
		Assign(fIn, source);
		Reset(fIn);
		Assign(fOut, target);
		ReWrite(fOut);
		repeat
			BlockRead(fIn, buffer, fsBufferSize, numRead);
			BlockWrite(fOut, buffer, numread, numWritten);
		until (numRead = 0) or
				(not (numRead = numWritten));
		Close(fOut);
		Close(fIn);
	except
		on e: Exception do
			FsCopyFile := false;
	end;
end;

(*===converts StreamFS path to DOS path===*)
function StreamFSToDOS(streamFsPath: String): String;
var
	out_s, tmp, rpath: String;
	i, ppos, k: Longint;
begin
	out_s := '';
	tmp := streamFsPath;
	(*replace \ with /*)
	for i := 1 to Length(tmp) do
		if tmp[i] = '/' then
			tmp[i] := '\';
	(*finds path according to fstab*)
	for k := 1 to Length(kernelFsTab) - 1 do
		begin
			ppos := Pos(kernelFsTab[k].mountpoint, streamFsPath);
			if ppos = 1 then
				begin
					if kernelFsTab[k].source[Length(kernelFsTab[k].source)] = '\' then
						out_s := kernelFsTab[k].source
					else
						out_s := kernelFsTab[k].source + '\';
					rpath := Copy(tmp, Length(kernelFsTab[k].mountpoint) + 1, Length(tmp) - Length(kernelFsTab[k].mountpoint));
					out_s += rpath;
					break;
				end;
		end;
	(*if nothing to do, return the same*)
	if out_s = '' then
		out_s := tmp;
	StreamFSToDOS := out_s;
end;

(*===checks file existing===*)
function FsFileExists(filePath: String; filetype: TFileType): Boolean;
var
	info : TSearchRec;
begin
	if fileType = tft_file then
		begin
			if FindFirst(StreamFSToDOS(filePath), faarchive, info) = 0 then
				FsFileExists := true
			else
				FsFileExists := false;
		end
	else
		if fileType = tft_directory then
			begin
				if FindFirst(StreamFSToDOS(filePath), fadirectory, info) = 0 then
					FsFileExists := true
				else
					FsFileExists := false;
			end
		else
			FsFileExists := false;
end;

begin
	SetLength(kernelFsTab, 1);
end.

