@echo off
shsucdx.exe /D:STCD
findcd.exe
if "%errorlevel%"=="26" set CDROM=Z
if "%errorlevel%"=="25" set CDROM=Y
if "%errorlevel%"=="24" set CDROM=X
if "%errorlevel%"=="23" set CDROM=W
if "%errorlevel%"=="22" set CDROM=V
if "%errorlevel%"=="21" set CDROM=U
if "%errorlevel%"=="20" set CDROM=T
if "%errorlevel%"=="19" set CDROM=S
if "%errorlevel%"=="18" set CDROM=R
if "%errorlevel%"=="17" set CDROM=Q
if "%errorlevel%"=="16" set CDROM=P
if "%errorlevel%"=="15" set CDROM=O
if "%errorlevel%"=="14" set CDROM=N
if "%errorlevel%"=="13" set CDROM=M
if "%errorlevel%"=="12" set CDROM=L
if "%errorlevel%"=="11" set CDROM=K
if "%errorlevel%"=="10" set CDROM=J
if "%errorlevel%"=="9" set CDROM=I
if "%errorlevel%"=="8" set CDROM=H
if "%errorlevel%"=="7" set CDROM=G
if "%errorlevel%"=="6" set CDROM=F
if "%errorlevel%"=="5" set CDROM=E
if "%errorlevel%"=="4" set CDROM=D
if "%errorlevel%"=="3" set CDROM=C
if "%errorlevel%"=="2" set CDROM=B
if "%errorlevel%"=="1" set CDROM=A
