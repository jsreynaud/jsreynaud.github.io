#!/bin/bash -e

PWD=$(dirname $0)
BACKDAY=${1:-2}
echo "Start"
date
TMP=$(mktemp)
echo "Extrat data from $(date -d "$BACKDAY days ago" +"%Y-%m-%d") to now"
$PWD/stat.py $(date -d "$BACKDAY days ago" +"%Y-%m-%d") > $TMP

for((hday=${BACKDAY};hday>=0;hday--)); do
    DATETODOWNLOAD=$(date -d "$hday days ago" +"%Y-%m-%d")
    MONTHTODOWNLOAD=$(date -d "$hday days ago" +"%Y-%m")
    YEARTODOWNLOAD=$(date -d "$hday days ago" +"%Y")

    echo "Rebuild for ${DATETODOWNLOAD}"
    mkdir -p $PWD/csv/${MONTHTODOWNLOAD}
    rm -f $PWD/csv/${MONTHTODOWNLOAD}/${DATETODOWNLOAD}.txt $PWD/csv/${MONTHTODOWNLOAD}.txt
    (head -1 ${TMP};grep "\"${DATETODOWNLOAD}\"" $TMP | sort) > $PWD/csv/${MONTHTODOWNLOAD}/${DATETODOWNLOAD}.txt

    ##rm  $PWD/csv/OTHER.txt
    ##(head -1 $TMP;grep -v "\"${DATETODOWNLOAD}\"" $TMP) > $PWD/csv/OTHER.txt

    echo "Rebuild monthly stats"
    (head -q -n 1 $PWD/csv/${MONTHTODOWNLOAD}/*.txt | head -1;tail -q -n +2 $PWD/csv/${MONTHTODOWNLOAD}/*.txt | sort) > $PWD/csv/${MONTHTODOWNLOAD}.txt

    echo "Rebuild for ${YEARTODOWNLOAD}"
    (head -1 ${TMP};tail -q -n +2 $PWD/csv/${YEARTODOWNLOAD}-*.txt | sort) > $PWD/csv/${YEARTODOWNLOAD}.txt

    echo "Building dataset"
    (
        echo '"Package","Item","Title","csv"'
        find $PWD/csv/ -regex '.*/[0-9]+.txt' | while read year; do
            YEAR=$(basename $year .txt);
            echo "\"Yearly\",\"$YEAR\",\"$(date -d "$YEAR-01-01" +"%B %Y")\",\"csv/${YEAR}.txt\""
        done

        ls -1 $PWD/csv/*-*.txt | while read month; do
            MONTH=$(basename $month .txt)
            echo "\"Monthly\",\"$MONTH\",\"$(date -d "$MONTH-01" +"%B %Y")\",\"csv/${MONTH}.txt\""
        done

        ls -1 $PWD/csv/*-*.txt | while read month; do
            MONTH=$(basename $month .txt)
            ls -1 $PWD/csv/$MONTH/*.txt | while read day; do
                DAY=$(basename $day .txt)
                echo "\"Daily for $(date -d "$MONTH-01" +"%B %Y")\",\"$DAY\",\"$(date -d "$DAY" +"%d %B %Y")\",\"csv/${MONTH}/${DAY}.txt\""
            done
        done

    ) > $PWD/datasets.csv

done

rm -f ${TMP}
date
echo "End"
