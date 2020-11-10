#!/bin/bash 

 display_usage() { 
	echo "
Usage:
    $(basename "$0") <query_list> [--help or -h]

Description:
    Runs tcdpds queries from queries folder

Arguments:
    query_list: query list file"

}




# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
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



QUERIES=$(cat $1)
BEELINE="hive --database tpcds_orc_10000"
DT=$(date +%Y-%m-%d.%s)

mkdir -p results/$DT

for q in $QUERIES; do 
	$BEELINE -f ./queries/$q 2>&1 | tee results/$DT/$q.txt
done
