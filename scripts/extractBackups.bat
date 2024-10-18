@echo off
@ren Read config file
for /f "tokens=1,2 delims==" %%a in (..\config.txt) do (
    if %%a==fullBackupDir set fullBackupDir=%%b
    if %%a==diffBackupDir set diffBackupDir=%%b
    if %%a==logBackupDir set logBackupDir=%%b
    if %%a==extractDir set extractDir=%%b
    if %%a==scriptLogs set scriptLogs=%%b
)

md %scriptLogs%
@SETLOCAL ENABLEDELAYEDEXPANSION
where /r %fullBackupDir% *.zip > %scriptLogs%\list.txt
where /r %diffBackupDir% *.zip >> %scriptLogs%\list.txt
where /r %logBackupDir% *.zip >> %scriptLogs%\list.txt

rd /s /q %extractDir%
md %extractDir%
echo Extracting backups...
for /F "delims=" %%i in ('type %scriptLogs%\list.txt') do (  
  ..\7z\7za.exe x %%i -o%extractDir% > nul 2>&1
)
echo Backup extraction finished.
echo You can find the extracted backups in %extractDir%.
del %scriptLogs%\list.txt
pause
exit
