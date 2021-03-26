#!/bin/bash
export PGPASSFILE=/root/.pgpass
PATH1C="/opt/1C/v8.3/x86_64"

helpFunction()
{
   echo ""
   echo "Использование: $0 -n НазваниеКлиента -t Конфигурация -c КоличествоБаз"
   echo "\t-n Название клиента"
   echo "\t-t Конфигурация"
   echo "\t-c Количество баз"
   exit 1
}

while getopts "n:t:c:" opt
do
   case "$opt" in
      n ) CompanyName="$OPTARG" ;;
      t ) ConfigurationTemplate="$OPTARG" ;;
      c ) CountOfBases="$OPTARG" ;;
      ? ) helpFunction ;; 
   esac
done

if [ -z "$CompanyName" ] || [ -z "$ConfigurationTemplate" ] || [ -z "$CountOfBases" ]
then
   echo "Есть отсутствующие параметры";
   helpFunction
fi

ClusterUUID=$($PATH1C/rac cluster list | grep 'cluster ' | tail -c 37)
count=1
while [ $count -le $CountOfBases ]
do
   BaseName=$CompanyName'_'$ConfigurationTemplate'_'$count
   STRING="'CREATE DATABASE "$BaseName" WITH TEMPLATE "$ConfigurationTemplate" OWNER postgres;'"
   psql -U postgres -c "'SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '"$ConfigurationTemplate"' AND pid <> pg_backend_pid();'"
   psql -U postgres -c 'CREATE DATABASE '$BaseName' WITH TEMPLATE '$ConfigurationTemplate' OWNER postgres;'
   $PATH1C/rac infobase --cluster=$ClusterUUID create --create-database --name=$BaseName --dbms=PostgreSQL --db-server=localhost --db-name=$BaseName --locale=ru --db-user=postgres --db-pwd='pgpass'  --license-distribution=allow
   sudo mkdir '/var/www/'$BaseName
   $PATH1C/webinst -publish -apache24 -wsdir $BaseName -dir '/var/www/'$BaseName -connstr "Srvr=localhost;Ref="$BaseName";" -confpath /etc/apache2/apache2.conf
   count=$((count + 1))
done

sudo systemctl restart apache2
