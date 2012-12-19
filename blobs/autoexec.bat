@echo off

echo Setting environment...
set PATH=\sys\mods
echo Loading Keyrus...
cd \sys\drv\keyrus
call keyrus.bat
echo Loading CD-ROM drivers...
cd \sys\drv\cdrom
call cdrom.bat
echo Setting up RAM-disk Z:...
cd \sys\drv\xmsdisk
call xmsdisk.bat
cd \

set PATH=\sys\mods;%CDROM%:\bin;%CDROM%:\sys\kernel;%CDROM%:\sys\mods
set DPMILDR=1024

echo Starting StreamOS kernel...
:cycle
DPMILD32 STREAMOS.EXE root=%CDROM% debug=text
echo Kernel panic.

echo Press any key to restart StreamOS kernel...
pause >nul
goto cycle

:end
