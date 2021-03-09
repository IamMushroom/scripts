#!/bin/sh

BASES=`sudo -u postgres psql -A -q -t -c "select datname from pg_database" template1`
TIME=`date +"%d-%m-%y_%T"`
DATE=`date +"%d-%m-%y"`

#Задаём параметры хранения
KEEP=14 #Сколько дней храним бэкапы
BACKUPDIR="/home/backup/1CBackup" #Пусть к папке с бэкапами
LOGDIR="/var/log/1CBackup" #Путь к папке с логами

#Задаём параметры аторизации
#PGUSER=postgres
#PGPASSWORD=pgpass
PGPASSFILE=/root/.pgpass

#Бэкапим все базы (включая служебные)
for i in $BASES
do
  if [ ! -d "$LOGDIR/$i" ]; then
    mkdir "$LOGDIR/$i"
  fi
  TIME=`date +"%d-%m-%y_%T"`
  echo "$TIME: Start backup of database" >> $LOGDIR/$i/$DATE.log
  if [ ! -d "$BACKUPDIR/$i" ]; then
    mkdir "$BACKUPDIR/$i"
  fi

  pg_dump $i -U dbadmin --format=custom --file=$BACKUPDIR/$i/$i_$TIME.backup
  
  TIME=`date +"%d-%m-%y_%T"`
  echo "$TIME: Finish backup of database" >> $LOGDIR/$i/$DATE.log
done

#Удаляем старые бэкапы
find $BACKUPDIR/* -name "*.backup" -atime +$KEEP | xargs rm -rf