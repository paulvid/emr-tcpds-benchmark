#!/bin/bash 
set -o nounset

display_usage() { 
    echo "
Usage:
    $(basename "$0") [--help or -h] <date_folder>

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

date_folder=$1
query_folder=$(echo $date_folder | sed s/-/_/g)

file=$(java -cp EMR.jar com.cloudera.utils.CreateDummyQueryData   logs/$date_folder | grep "Hive protos will be saved to file" | awk -F ":" '{print $2}')

mkdir -p ./logs/$date_folder/hive/query_data
rm -rf ./logs/$date_folder/hive/query_data/*
mkdir -p ./logs/$date_folder/hive/query_data/$query_folder
cp $file ./logs/$date_folder/hive/query_data/$query_folder/


cd logs/$date_folder
tar -czvf "$date_folder"-tez.tar.gz tez
tar -czvf "$date_folder"-hive.tar.gz hive
cd -