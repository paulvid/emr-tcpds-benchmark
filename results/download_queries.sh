#!/bin/bash 
set -o nounset

display_usage() { 
    echo "
Usage:
    $(basename "$0") [--help or -h] <host>

Description:
    Downloads queries txt

Arguments:
    host:   host from which to download logs
    --help or -h:   displays this help"

}

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( ${1:-x} == "--help") ||  ${1:-x} == "-h" ]] 
then 
    display_usage
    exit 0
fi 


# Check the numbers of arguments
if [  $# -lt 1 ] 
then 
    echo "Not enough arguments!"  >&2
    display_usage
    exit 1
fi 

if [  $# -gt 1 ] 
then 
    echo "Too many arguments!"  >&2
    display_usage
    exit 1
fi 

host=$1

#local
date_folder=$(date +"%Y-%m-%d.%s")
rm -rf queries/$date_folder.tar.gz
rm -rf queries/$date_folder/

# remote
ssh hadoop@${host} rm $date_folder.tar.gz
folder=$(ssh hadoop@${host} ls -ltra tcpds/results/ | grep 2020 | tail -1 | awk '{print $9}')
ssh hadoop@${host} tar -czvf $date_folder.tar.gz tcpds/results/${folder}/*
scp hadoop@${host}:$date_folder.tar.gz queries/

tar -xvf queries/$date_folder.tar.gz
mkdir -p queries/$date_folder/
mv tcpds/results/$folder/* queries/$date_folder/
rm -rf tcpds/