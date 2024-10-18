@ren Read config file
for /f "tokens=1,2 delims==" %%a in (..\config.txt) do (
    if %%a==dbName set dbName=%%b
    if %%a==serverName set serverName=%%b
    if %%a==logBackupDir set logBackupDir=%%b
    if %%a==scriptLogs set scriptLogs=%%b
)

@ren Create required folders if they don't exist
md %logBackupDir%
md %scriptLogs%

move /Y %scriptLogs%\trnLog.txt %scriptLogs%\trnTmp.txt
time /t > %scriptLogs%\trnLog.txt
date /t >> %scriptLogs%\trnLog.txt

@SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=1,2 delims==" %%i in ('wmic os get LocalDateTime /VALUE 2^>nul') do (
    if ".%%i."==".LocalDateTime." set mydate=%%j
)
set datetime=%mydate:~0,4%-%mydate:~4,2%-%mydate:~6,2%_%mydate:~8,2%-%mydate:~10,2%-%mydate:~12,2%
set filename=%logBackupDir%\log_!datetime!.trn

set count=0
for %%x in ("%logBackupDir%\*.zip") do set /a count+=1
IF %count%==100 goto :del

:breakLoop
sqlcmd -E -S %serverName% -Q "BACKUP LOG %dbName% TO DISK = '%filename%' WITH FORMAT, MEDIANAME='Backups'" >> %scriptLogs%\trnLog.txt
sqlcmd -E -S %serverName% -Q "DBCC SHRINKFILE (%dbName%_log, 1)" >> %scriptLogs%\trnLog.txt

echo Compressing backup... >> %scriptLogs%\trnLog.txt
..\7z\7za.exe a -tzip %filename%.zip %filename% >> %scriptLogs%\trnLog.txt
echo Backup compression finished. >> %scriptLogs%\trnLog.txt
type %scriptLogs%\trnTmp.txt >> %scriptLogs%\trnLog.txt
del %scriptLogs%\trnTmp.txt
fsutil file seteof %scriptLogs%\trnLog.txt 1048576
del %filename%
exit

:del
for /f "delims=" %%a in ('dir /b /a-d /t:w /o:d "%logBackupDir%\*.zip"') do (
    del "%logBackupDir%\%%a"
    goto :breakLoop
)
