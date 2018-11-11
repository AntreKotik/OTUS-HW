#!/bin/bash

awk -v threshold=$(date "--date=$(date) -1 hour" +%d%b%y:%T) \
 'BEGIN { FS == " \\[?"} 
    { if ($4 < threshold && $6 ~ \"[A-Z]+ ) print $6, $9}' test

