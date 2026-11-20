@echo off
REM Makes dist\<ModuleName>.zip from the module's DLL, .t file and package-list.txt.
REM Usage:  scripts\package-module.bat
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0package-module.ps1"
set "RESULT=%errorlevel%"
if not defined MODULE_BUILD_NOPAUSE pause
exit /b %RESULT%
