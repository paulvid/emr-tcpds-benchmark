#!/bin/bash 
set -o nounset

display_usage() { 
    echo "
Usage:
    $(basename "$0") [--help or -h] <date_folder>

Description:
    Create csv with all query data

Arguments:
    date_folder:    folder where queries are
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
rm queries/$date_folder/queries_stats.csv

echo "query_id, status, time, rows" >> queries/$date_folder/queries_stats.csv
for file in $(ls queries/$date_folder/*.sql.txt)
do
    query_id=$(echo $file | awk -F "/" '{print $3}' | awk -F "." '{print $1}')
    last_line=$(tail -1 $file)

    if [[ $last_line = Time* ]] 
    then
        status="success"
        time=$(echo $last_line | awk '{print $3}')
        rows=$(echo $last_line | awk '{print $6}')
    else
        status="failed"
        time="0.0"
        rows="0"
    fi
    echo $query_id", "$status", "$time", "$rows >> queries/$date_folder/queries_stats.csv
done