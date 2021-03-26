$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

#Задаём параметры хранения
#$KEEP=14 #Сколько дней храним бэкапы
$BACKUPDIR="D:\Backup\1CBackup" #Пусть к папке с бэкапами
$LOGDIR="D:\Backup\Logs" #Путь к папке с логами

#Задаём параметры аторизации
#$env:PGUSER=postgres
#$env:PGPASSWORD=pgpass
$env:PGPASSFILE="C:\Users\owner\pgpass.conf"

$PGPATH="C:\Program Files\PostgreSQL\12.4-1.1C\bin"
Set-Location $PGPATH
$BASES=.\psql -U postgres -A -q -t -c "select datname from pg_database" template1
$DATE=Get-Date -Format "dd-MM-yy"

if ( -not (Test-Path "$LOGDIR")) {
  New-Item -ItemType "directory" -Path "$LOGDIR"
}
if ( -not (Test-Path "$BACKUPDIR")) {
  New-Item -ItemType "directory" -Path "$BACKUPDIR"
}

#Бэкапим все базы (включая служебные)
ForEach ($i in $BASES)
{
  if ( -not (Test-Path "$LOGDIR\$i")) {
    New-Item -ItemType "directory" -Path "$LOGDIR\$i"
  }
  $TIME=Get-Date -Format "dd-MM-yy_HH:mm"
  if ( -not (Test-Path -PathType Leaf -Path "$LOGDIR\$i\$DATE.log")) {
  New-Item -Name "$DATE.log" -Path "$LOGDIR\$i"
  }
  Write-Output "$TIME : Start backup of database" >> $LOGDIR/$i/$DATE.log
  if ( -not (Test-Path "$BACKUPDIR\$i")) {
    New-Item -ItemType "directory" -Path "$BACKUPDIR\$i"
  }

  .\pg_dump -U postgres -F custom -f "$BACKUPDIR/$i/$DATE.backup" -v $i
  
  $TIME=Get-Date -Format "dd-MM-yy_HH:mm"
  Write-Output "$TIME : Finish backup of database" >> $LOGDIR/$i/$DATE.log
}
