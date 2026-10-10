#!/bin/bash

if [ $# != 2 ]
then
    echo "usage: ./restore.sh dir malicious_dir"
    exit
fi

dir=$1
mdir=$2

while true
do
    # asking is the quarantine empty
    count=$(ls $mdir | wc -l)
    if [ $count = 0 ]
    then
        echo "No malicious files to review."
        exit
    fi

    # list files with numbers
    i=1
    for f in $mdir/*
    do
        echo "$i) $(basename "$f")"
        i=`expr $i + 1`
    done

    echo "Pick a file number (0 to quit):"
    read num

    if [ "$num" = "0" ]
    then
        exit
    fi

    # find the file with this number
    file=""
    c=0
    for f in $mdir/*
    do
        c=`expr $c + 1`
        if [ "$c" = "$num" ]
        then
            file=$(basename "$f")
        fi
    done

    if [ -z "$file" ]
    then
        echo "Invalid number"
    else
        echo "File: $file"
        echo "1: Restore this file back into $dir (supposed malicious by mistake )"
        echo "2: Permanently delete this file (genuinely malicious)"
        echo "3: Leave this file as-is and go back to the list"
        read choice

        if [ "$choice" = "1" ]
        then
            cp "$mdir/$file" "$dir/$file"
            rm "$mdir/$file"
            echo "$file" >> whitelist.txt
            echo "Restored $file to $dir."
        elif [ "$choice" = "2" ]
        then
            rm "$mdir/$file"
            echo "$file permanently deleted."
        else
            echo "Left $file as is."
        fi
    fi
done

