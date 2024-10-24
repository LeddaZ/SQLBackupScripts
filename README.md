# SQL Server Backup Scripts

## config.txt instructions

The file must be created in this path.

- `serverName` – Name of the SQL Server instance

![serverName](./img/serverName.png)

- `dbName` – Database name
- `fullBackupDir`, `diffBackupDir`, `logBackupDir` – Paths for full backups, differential backups and log backups respectively
- `scriptLogs` – Path for logs generated by the scripts
- `extractDir` - Path where backups will be extracted when running the appropriate script

The paths don't have to exist already, the scripts will create them if necessary; **paths can't have spaces**.

### Example

```
dbName=asdf
serverName=DESKTOP-4NU75CF
fullBackupDir=D:\Backup\Backups\Full
diffBackupDir=D:\Backup\Backups\Diff
logBackupDir=D:\Backup\Backups\Logs
scriptLogs=D:\Backup\Logs
extractDir=D:\Backup\Extracted
```

## Scripts

- The full backup script compresses it into zip format after creation, using 7zip (in the `7z` folder); once compression is complete it deletes the uncompressed file. Two backups are kept, when the third is created the oldest is deleted first.
- Differential backups are saved in a folder named with the timestamp of the last full backup, to be used as a base for restore. When a new full backup is created the folder in question is deleted, and a new one is created with the new timestamp for subsequent differential backups.
- Up to 100 log backups are kept (about a day of backups if done every 15 minutes). The log file is shrunk after every backup.
- The backup extraction script creates a list of all `.zip` files in `fullBackupDir`, `diffBackupDir`, `logBackupDir`, then it extracts them in `extractDir`.

## Schedules

- **SQL Full Backup**: runs the full backup scripts every Sunday at 3 AM.
- **SQL Diff Backup**: runs the differential backup script every day at 4 AM.
- **SQL Log Backup**: runs the log backup script every 15 minutes.
