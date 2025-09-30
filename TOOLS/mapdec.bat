@ECHO OFF
IF "%OS%" == "Windows_NT" GOTO Windows_NT
REM %* works for cmd.exe, not command.com
..\bin\roxfxb.exe mapdec %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO End

:Windows_NT
.\robfxs.exe argonautmapdecoder %*

:End
