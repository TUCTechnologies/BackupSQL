$BackupDir = "D:\SQL Backups"
$Databases = @("Production")
$BackupExt = "sql.bak"
$7zipExt = "7z"

# Perform backup of SQL database then compress with 7-zip
ForEach($Database in $Databases)
{
  $Now = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

  Write-Host "Backing up: $Database"
  & "C:\Program Files\Microsoft SQL Server\100\Tools\Binn\osql.exe" -E -Q "BACKUP DATABASE $Database TO DISK = '$BackupDir\$Database.$Now.$BackupExt' WITH INIT, STATS = 10"

  Write-Host "Compressing: $Database"
  & "C:\Program Files\7-Zip\7z.exe" a -t7z "$BackupDir\$Database.$Now.$BackupExt.$7zipExt" "$BackupDir\$Database.$Now.$BackupExt" -m0=lzma2 -mx3 -mmt=on -mhe=on -ssw -y

  Remove-Item "$BackupDir\$Database.$Now.$BackupExt"

  # Delete old backups of the database
  $backupFiles = Get-ChildItem -Path "$BackupDir\$Database.*.7z" | Sort-Object name -Descending
  $backupsToKeep = 5

  ForEach($backupFile in $backupFiles) {
	If($backupsToKeep -gt 0) {
		Write-Host "Keeping recent backup: $backupFile"
		$backupsToKeep--;
	}
	Else {
		Write-Host "Deleting old backup: $backupFile"
		Remove-Item $backupFile
	}
  }
}
