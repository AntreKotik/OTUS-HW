#!/bin/bash

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
mdadm --create --verbose /dev/md0 --level=10 --layout=f2 --raid-devices=5 /dev/sd[bcdef] --spare-devices=1 /dev/sdg
mdadm --detail /dev/md0 

parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

for i in $(seq 1 5)
do 
    mkfs.ext4 /dev/md0p$i
done 

mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5)
do 
    mount /dev/md0p$i /raid/part$i
done


