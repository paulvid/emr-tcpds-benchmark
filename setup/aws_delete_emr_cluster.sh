#!/bin/bash 
source $(cd $(dirname $0); pwd -L)/common.sh

 display_usage() { 
	echo "
Usage:
    $(basename "$0") <parameter_file> [--help or -h]

Description:
    Creates AWS pre-requisites

Arguments:
    parameter_file: location of your emr parameter json file"

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

# Parsing arguments
parse_parameters ${1}


# AWS pre-requisites (per env)
echo "⏱  $(date +%H%Mhrs)"
echo ""
echo "Deleting EMR cluster for $prefix:"
underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
for ((i=1;i<=$prefix_length;i++))
do
    underline=${underline}"▔"
done
echo ${underline}


all_clusters=$(aws emr list-clusters 2> /dev/null)

for row in $(echo ${all_clusters} | jq -r '.Clusters[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    cluster_name=$(_jq '.Name')

    if [[ $cluster_name == "$prefix-emr-cluster" ]]
    then 
        cluster_id=$(_jq '.Id')
        result=$(aws emr terminate-clusters --cluster-id $cluster_id)
        handle_exception $? $prefix "deleting EMR cluster" $result


        cluster_status=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Status.State)

        spin='🌑🌒🌓🌔🌕🌖🌗🌘'
        while [[ "$cluster_status" != "TERMINATED" && "$cluster_status" != "TERMINATED_WITH_ERRORS" ]]
        do 
            i=$(( (i+1) %8 ))
            printf "\r${spin:$i:1}  $prefix: $cluster_name (cluster id: $cluster_id) emr cluster status: $cluster_status                           "
            sleep 2
            cluster_status=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Status.State)
        done

        printf "\r${CHECK_MARK}  $prefix: $cluster_name (cluster id: $cluster_id) emr cluster status: $cluster_status                            "
        echo ""
    fi 

done


echo ""
echo "EMR clusters deleted for $prefix!"
echo ""