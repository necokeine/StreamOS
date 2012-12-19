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

program
	suspend;
uses
	apmlib,
	crt;
var
	max, min: Byte;
begin
	if apmlib.APMIsInstalled then
		begin
			APMGetVer(max, min);
			if (max >= 1) and
				(min >= 1) then
				begin
					apmlib.FlushAllCaches;
					crt.Delay(1000);
					apmlib.Suspend;
				end
			else
				Halt(1);
		end
	else
		Halt(2);
end.

