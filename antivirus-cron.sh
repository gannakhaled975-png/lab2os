#!/bin/bash
base=/home/gannah/lab2os
dir=$base/test_dir
mdir=$base/malicious_dir

# cron starts at second 0 so iwill wait 23 seconds
sleep 23

cd $base
mkdir -p $mdir

scan() {
    for file in $dir/*
    do
        if [ -f "$file" ]
        then
            n=$(basename "$file")
            bad=0
            safe=0

            if [ -f whitelist.txt ]
            then
                if grep -x -F "$n" whitelist.txt > /dev/null
                then
                    safe=1
                fi
            fi

            if echo "$n" | grep -E "\.(exe|bat|vbs|scr|ps1)$" > /dev/null
            then
                bad=1
            fi

            if grep -i -E "virus|trojan|malware|worm|ransomware" "$file" > /dev/null
            then
                bad=1
            fi

            if [ $bad = 1 ] && [ $safe = 0 ]
            then
                echo "$n is malicious and it is DELETED"
                cp "$file" "$mdir/$n"
                rm "$file"
            fi
        fi
    done
}

if [ ! -f directory-info.last ]
then
    scan
    ls -l $dir > directory-info.last
else
    ls -l $dir > directory-info.new
    diff directory-info.new directory-info.last > /dev/null
    if [ $? != 0 ]
    then
        scan
        cp directory-info.new directory-info.last
    fi
fi

