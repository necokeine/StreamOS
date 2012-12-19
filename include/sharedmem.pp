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

{$MODE OBJFPC}
{$SMARTLINK OFF}

unit
	sharedmem;

interface

{$i config.inc}

implementation

{$ifdef use_shared_memory}
	procedure GetMemMan(out MemMan : TMemoryManager); stdcall; external 'smem' name 'GetSharedMemoryManager';
	var
		MemMan: TMemoryManager;
	initialization
		GetMemMan(MemMan);
		SetMemoryManager(MemMan);
{$endif}
end.

