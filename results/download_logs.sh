#!/bin/bash 
set -o nounset

display_usage() { 
    echo "
Usage:
    $(basename "$0") [--help or -h] <host>

Description:
    Downloads tez AM logs

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
rm -rf logs/$date_folder.tar.gz
rm -rf logs/$date_folder/

# remote
ssh hadoop@${host} mkdir -p logs/$date_folder
ssh hadoop@${host} rm -rf logs/$date_folder/*
ssh hadoop@${host} hdfs dfs -copyToLocal /tez_logs/* logs/$date_folder/
ssh hadoop@${host} tar -czvf logs/$date_folder.tar.gz logs/$date_folder/
scp hadoop@${host}:logs/$date_folder.tar.gz logs/



tar -xvf logs/$date_folder.tar.gz

mkdir -p logs/$date_folder/tez
mv logs/$date_folder/dag_data logs/$date_folder/tez/
mv logs/$date_folder/dag_meta logs/$date_folder/tez/
mv logs/$date_folder/app_data logs/$date_folder/tez/