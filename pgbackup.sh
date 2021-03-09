#!/bin/sh

BASES=`sudo -u postgres psql -A -q -t -c "select datname from pg_database" template1`
TIME=`date +"%d-%m-%y_%T"`
DATE=`date +"%d-%m-%y"`
BACKUPDIR="/home/backup/1CBackup"
LOGDIR="/var/log/1CBackup"
#PGUSER=postgres
#PGPASSWORD=pgpass
PGPASSFILE=/root/.pgpass

for i in $BASES
do
  if [ ! -d "$LOGDIR/$i" ]; then
    mkdir "$LOGDIR/$i"
  fi
  echo "$TIME: Start backup of %i database" > $LOGDIR/$i/$TIME.log
  if [ ! -d "$BACKUPDIR/$i" ]; then
    mkdir "$BACKUPDIR/$i"
  fi

  pg_dump $i -U dbadmin --format=custom --file=$BACKUPDIR/$i/$i_$TIME.backup
  echo "$TIME: Finish backup of %i database" >> $LOGDIR/$i/$TIME.log
done
