#!/bin/bash

#awk 'BEGIN { FS = " \[?"} { if ( $6 ~ "\"[A-Z]+" ) print $1, $4, $7 }' access.log
#awk 'BEGIN { FS = " \[?"} { if ( $6 ~ "\"[A-Z]+" ) split($4,a,"/"); split(a[3],b,":"); date2conv = a[1]" "a[2]" "b[1]" "b[2]":"b[3]":"b[4]; cmd = "date --date=\""date2conv"\" +%s\"\""; cmd | getline seconds; print $1, seconds, $7 }' access.log

time2check=$(($1-3600))

echo $time2check

awk -v start="$time2check" 'BEGIN { FS = " \[?"} { 
    split($4,a,"/"); 
    split(a[3],b,":"); 
    date2conv = a[1]" "a[2]" "b[1]" "b[2]":"b[3]":"b[4];
    cmd = "date --date=\""date2conv"\" +%s\"\""; 
    cmd | getline seconds; 
    if ($6 ~ "\"[A-Z]+" && seconds > start)
    print $1, seconds, start, $7 }' access.log

