@ren Lettura file di configurazione
for /f "tokens=1,2 delims==" %%a in (..\config.txt) do (
    if %%a==dbName set dbName=%%b
    if %%a==serverName set serverName=%%b
    if %%a==fullBackupDir set fullBackupDir=%%b
    if %%a==diffBackupDir set diffBackupDir=%%b
    if %%a==scriptLogs set scriptLogs=%%b
)

@ren Crea le cartelle necessarie se non esistono già
md %fullBackupDir%
md %diffBackupDir%
md %scriptLogs%

move /Y %scriptLogs%\fullLog.txt %scriptLogs%\fullTmp.txt
time /t > %scriptLogs%\fullLog.txt
date /t >> %scriptLogs%\fullLog.txt

@SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=1,2 delims==" %%i in ('wmic os get LocalDateTime /VALUE 2^>nul') do (
    if ".%%i."==".LocalDateTime." set mydate=%%j
)
set datetime=%mydate:~0,4%-%mydate:~4,2%-%mydate:~6,2%_%mydate:~8,2%-%mydate:~10,2%-%mydate:~12,2%
set filename=%fullBackupDir%\full_!datetime!.bak

set count=0
for %%x in ("%fullBackupDir%\*.zip") do set /a count+=1
IF %count%==2 goto :del

:breakLoop
sqlcmd -E -S %serverName% -Q "BACKUP DATABASE %dbName% TO DISK = '%filename%' WITH FORMAT, MEDIANAME='Backups'" >> %scriptLogs%\fullLog.txt

md %diffBackupDir%\%datetime%
echo %datetime% > %diffBackupDir%\latestfull.txt
fsutil file seteof %diffBackupDir%\latestfull.txt 19
echo Compressione del backup in corso... >> %scriptLogs%\fullLog.txt
..\7z\7za.exe a -tzip %filename%.zip %filename% >> %scriptLogs%\fullLog.txt
echo Compressione del backup completata. >> %scriptLogs%\fullLog.txt
type %scriptLogs%\fullTmp.txt >> %scriptLogs%\fullLog.txt
del %scriptLogs%\fullTmp.txt
fsutil file seteof %scriptLogs%\fullLog.txt 1048576
del %filename%
exit

:del
set /p latestfull=<%diffBackupDir%\latestfull.txt
for /f "delims=" %%a in ('dir /b /a-d /t:w /o:d "%fullBackupDir%\*.zip"') do (
    del "%fullBackupDir%\%%a"
    rd /s /q "%diffBackupDir%\%latestfull%"
    goto :breakLoop
)
