@echo off
title Enable Windows Defender - Batch Edition
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::
echo This will immediately re-enable windows defender.
echo Press any key to start re-enabling windows defender
pause > nul
echo Setting up...
cd /d %~dp0
copy /Y %~dp0"bin\EnableDefenderWinDeploy.cmd" "C:\Temp.cmd"
reg add "HKLM\System\Setup" /v "CmdLine" /t REG_SZ /d "cmd.exe /c C:\Temp.cmd" /f
reg add "HKLM\System\Setup" /v "SystemSetupInProgress" /t REG_DWORD /d "1" /f
reg add "HKLM\System\Setup" /v "OOBEInProgress" /t REG_DWORD /d "1" /f
reg add "HKLM\System\Setup" /v "SetupType" /t REG_DWORD /d "2" /f
reg add "HKLM\System\Setup" /v "SetupPhase" /t REG_DWORD /d "4" /f
reg add "HKLM\System\Setup" /v "SetupSupported" /t REG_DWORD /d "1" /f
echo Restarting...
wmic os where primary=1 reboot
exit