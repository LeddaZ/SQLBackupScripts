@ren Lettura file di configurazione
for /f "tokens=1,2 delims==" %%a in (..\config.txt) do (
    if %%a==dbName set dbName=%%b
    if %%a==serverName set serverName=%%b
    if %%a==diffBackupDir set diffBackupDir=%%b
    if %%a==scriptLogs set scriptLogs=%%b
)

@ren Crea le cartelle necessarie se non esistono già
md %diffBackupDir%
md %scriptLogs%

move /Y %scriptLogs%\diffLog.txt %scriptLogs%\diffTmp.txt
time /t > %scriptLogs%\diffLog.txt
date /t >> %scriptLogs%\diffLog.txt

@SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=1,2 delims==" %%i in ('wmic os get LocalDateTime /VALUE 2^>nul') do (
    if ".%%i."==".LocalDateTime." set mydate=%%j
)
set datetime=%mydate:~0,4%-%mydate:~4,2%-%mydate:~6,2%_%mydate:~8,2%-%mydate:~10,2%-%mydate:~12,2%
set /p latestfull=<%diffBackupDir%\latestfull.txt
set filename=%diffBackupDir%\%latestfull%\diff_!datetime!.bak

sqlcmd -E -S %serverName% -Q "BACKUP DATABASE %dbName% TO DISK = '%filename%' WITH FORMAT, DIFFERENTIAL, MEDIANAME='Backups'" >> %scriptLogs%\diffLog.txt

echo Compressione del backup in corso... >> %scriptLogs%\diffLog.txt
..\7z\7za.exe a -tzip %filename%.zip %filename% >> %scriptLogs%\diffLog.txt
echo Compressione del backup completata. >> %scriptLogs%\diffLog.txt
type %scriptLogs%\diffTmp.txt >> %scriptLogs%\diffLog.txt
del %scriptLogs%\diffTmp.txt
fsutil file seteof %scriptLogs%\diffLog.txt 1048576
del %filename%
