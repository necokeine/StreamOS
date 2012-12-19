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
	lock;

interface

uses
	stypes;

{$i config.inc}

procedure InitLock(var locked: TLockContainer);
procedure EnterLock(var locked: TLockContainer);
procedure WaitLock(var locked: TLockContainer);
procedure LeaveLock(var locked: TLockContainer);
procedure DoneLock(var locked: TLockContainer);
function  IsLocked(locked: TLockContainer): Boolean;

{$ifdef collect_lock_statistic}
	var
		nr_init, nr_enter, nr_leave, nr_done, nr_wait, nr_is: Longint;
{$endif}

implementation

{$ifdef standard_lock}
	uses
		tools;
{$endif}

procedure InitLock(var locked: TLockContainer);
begin
	{$ifdef critical_lock}
		InitCriticalSection(locked.cs);
		locked.locked := false;
	{$endif}
	{$ifdef standard_lock}
		locked := false;
	{$endif}
	{$ifdef spin_lock}
		locked := -1;
	{$endif}
	{$ifdef spin_atomic_lock}
		locked := -1;
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_init);
	{$endif}
end;

procedure EnterLock(var locked: TLockContainer);
{$ifdef spin_atomic_lock}
	var
		temp: Longint;
{$endif}
begin
	{$ifdef critical_lock}
		EnterCriticalSection(locked.cs);
		locked.locked := true;
	{$endif}
	{$ifdef standard_lock}
		repeat
			Stay(10);
		until not locked;
		locked := true;
	{$endif}
	{$ifdef spin_lock}
		while InterlockedIncrement(locked) > 0 do
			Dec(locked);
	{$endif}
	{$ifdef spin_atomic_lock}
		repeat
			Inc(locked);
			temp := locked;
			if temp > 0 then
				Dec(locked);
		until not (temp > 0);
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_enter);
	{$endif}
end;

procedure LeaveLock(var locked: TLockContainer);
begin
	{$ifdef critical_lock}
		locked.locked := false;
		LeaveCriticalSection(locked.cs);
	{$endif}
	{$ifdef standard_lock}
		locked := false;
	{$endif}
	{$ifdef spin_lock}
		Dec(locked);
	{$endif}
	{$ifdef spin_atomic_lock}
		Dec(locked);
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_leave);
	{$endif}
end;

procedure WaitLock(var locked: TLockContainer);
begin
	{$ifdef critical_lock}
		EnterLock(locked);
		LeaveLock(locked);
	{$endif}
	{$ifdef standard_lock}
		repeat
			Stay(10);
		until not locked;
	{$endif}
	{$ifdef spin_lock}
		while locked > -1 do;
	{$endif}
	{$ifdef spin_atomic_lock}
		while locked > -1 do;
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_wait);
	{$endif}
end;

procedure DoneLock(var locked: TLockContainer);
begin
	{$ifdef critical_lock}
		locked.locked := false;
		DoneCriticalSection(locked.cs);
	{$endif}
	{$ifdef standard_lock}
		locked := false;
	{$endif}
	{$ifdef spin_lock}
		locked := -1;
	{$endif}
	{$ifdef spin_atomic_lock}
		locked := -1;
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_done);
	{$endif}
end;

function IsLocked(locked: TLockContainer): Boolean;
begin
	{$ifdef critical_lock}
		IsLocked := locked.locked;
	{$endif}
	{$ifdef standard_lock}
		IsLocked := locked;
	{$endif}
	{$ifdef spin_lock}
		IsLocked := locked > -1;
	{$endif}
	{$ifdef spin_atomic_lock}
		IsLocked := locked > -1;
	{$endif}
	{$ifdef collect_lock_statistic}
		inc(nr_is);
	{$endif}
end;

begin
	{$ifdef collect_lock_statistic}
		nr_init := 0;
		nr_enter := 0;
		nr_leave := 0;
		nr_done := 0;
		nr_wait := 0;
		nr_is := 0;
	{$endif}
end.

