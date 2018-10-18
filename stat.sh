#!/bin/bash

PWD=$(dirname $0)
DATETODOWNLOAD=$(date -d "2 days ago" +"%Y-%m-%d")
MONTHTODOWNLOAD=$(date -d "2 days ago" +"%Y-%m")

if [ -z "$1" ]; then
    TMP=$(mktemp)
    $PWD/stat.py $DATETODOWNLOAD > $TMP
    mkdir -p $PWD/csv/${MONTHTODOWNLOAD}
    rm -f $PWD/csv/${MONTHTODOWNLOAD}/${DATETODOWNLOAD}.txt $PWD/csv/${MONTHTODOWNLOAD}.txt
    (head -1 ${TMP};grep "\"${DATETODOWNLOAD}\"" $TMP) > $PWD/csv/${MONTHTODOWNLOAD}/${DATETODOWNLOAD}.txt
    rm -f ${TMP}
fi

##rm  $PWD/csv/OTHER.txt
##(head -1 $TMP;grep -v "\"${DATETODOWNLOAD}\"" $TMP) > $PWD/csv/OTHER.txt

# Rebuild monthly stats
(head -q -n 1 $PWD/csv/${MONTHTODOWNLOAD}/*.txt | head -1;tail -q -n +2 $PWD/csv/${MONTHTODOWNLOAD}/*.txt) > $PWD/csv/${MONTHTODOWNLOAD}.txt
(
echo '"Package","Item","Title","csv"'
ls -1 $PWD/csv/*.txt | while read month; do
    MONTH=$(basename $month .txt)
    echo "\"Monthly\",\"$MONTH\",\"$(date -d "$MONTH-01" +"%B %Y")\",\"csv/${MONTH}.txt\""
done

ls -1 $PWD/csv/*.txt | while read month; do
    MONTH=$(basename $month .txt)
    ls -1 $PWD/csv/$MONTH/*.txt | while read day; do
        DAY=$(basename $day .txt)
        echo "\"Daily for $(date -d "$MONTH-01" +"%B %Y")\",\"$DAY\",\"$(date -d "$DAY" +"%d %B %Y")\",\"csv/${MONTH}/${DAY}.txt\""
    done
done
) > $PWD/datasets.csv
