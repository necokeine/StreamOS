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
    testprint;

uses
    sysutils;

procedure printf(fmt:string;args:array of const);
var
    k, cnt, var_longint:longint;
    var_float:extended;
    ostring:string;
begin
  k:=1;
  ostring:='';
  cnt:=-1;
  repeat
    if fmt[k]='%' then
       begin
         inc(k);
         inc(cnt);
         if fmt[k]='d' then
            begin
              var_longint:=args[cnt].vinteger;
              ostring+=inttostr(var_longint);
            end
              else
         if fmt[k]='f' then
            begin
              var_float:=args[cnt].vextended^;
              ostring+=floattostr(var_float);
            end
       end
         else
    if fmt[k]='\' then
       begin
         inc(k);
         if fmt[k]='n' then
            ostring+=#10
              else
         if fmt[k]='\' then
            ostring+='\'
              else
         if fmt[k]='''' then
            ostring+=''''
              else
         if fmt[k]='"' then
            ostring+='"'
              else
         if fmt[k]='?' then
            ostring+='?';
       end
         else
    ostring+=fmt[k];
    inc(k);
  until k>length(fmt);
  write(ostring);
end;

var
    i:longint;
    l:extended;

begin
  i:=29;
  l:=29.123;
  printf('Here is a formatted number (d, f): %d, %f\nand escape-sequences: \\\''\"\?\n', [i, l]);
end.
