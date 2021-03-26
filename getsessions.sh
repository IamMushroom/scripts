#!bin/bash
PATH1C=/opt/1C/v8.3/x86_64
TMPFILE=$(mktemp /tmp/file.XXXXXXXX)

$PATH1C/rac cluster list >> $TMPFILE
n=$(cat $TMPFILE | wc -l)
n=$(($n/15))
i=1
while [ $i -le $n ]
do
    str=$((1+15*($i-1)))
    str=$str','$str'!d'
    cluster=$(cat $TMPFILE | sed $str | tail -c 37)
    clusters+=("$cluster")
    i=$[$i+1]
done
rm $TMPFILE
