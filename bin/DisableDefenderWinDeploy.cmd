@echo off
title Disable Windows Defender - Batch Edition
echo Disabling Windows Defender...
sc config WinDefend start=disabled
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f
echo Final touches...

reg add "HKLM\System\Setup" /v "CmdLine" /t REG_SZ /d "" /f
reg add "HKLM\System\Setup" /v "SystemSetupInProgress" /t REG_DWORD /d "0" /f
reg add "HKLM\System\Setup" /v "OOBEInProgress" /t REG_DWORD /d "0" /f
reg add "HKLM\System\Setup" /v "SetupType" /t REG_DWORD /d "0" /f
reg add "HKLM\System\Setup" /v "SetupPhase" /t REG_DWORD /d "0" /f
reg add "HKLM\System\Setup" /v "SetupSupported" /t REG_DWORD /d "1" /f
echo Restarting...
wmic os where primary=1 reboot
del /F /Q "C:\Temp.cmd"
pause > nul
exit
