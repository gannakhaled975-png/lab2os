#!/bin/bash

if [ $# != 3 ]
then
    echo "usage: ./antivirusd.sh dir malicious_dir interval-secs"
    exit
fi

dir=$1
mdir=$2
t=$3

mkdir -p $mdir

scan() {
    for file in $dir/*
    do
        if [ -f $file ]
        then
            n=$(basename $file)
            bad=0

            if echo $n | grep -E "\.(exe|bat|vbs|scr|ps1)$" > /dev/null
            then
                bad=1
            fi

            if grep -i -E "virus|trojan|malware|worm|ransomware" $file > /dev/null
            then
                bad=1
            fi

            if [ $bad = 1 ]
            then
                echo "$n is malicious and it is DELETED"
                cp $file $mdir/$n
                rm $file
            fi
        fi
    done
}

# first time
if [ ! -f directory-info.last ]
then
    scan
    ls -l $dir > directory-info.last
fi

while true
do
    sleep $t
    ls -l $dir > directory-info.new
    diff directory-info.new directory-info.last > /dev/null
    if [ $? != 0 ]
    then
        scan
        cp directory-info.new directory-info.last   
    fi
done

