#!/bin/bash 

source $(cd $(dirname $0); pwd -L)/common.sh

 display_usage() { 
	echo "
    Usage:
        $(basename "$0") <emr_parameter_file> [--help or -h]

    Description:
        Creates bucket, roles, and EMR cluster 

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


echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ Starting to delete all emr things ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""
echo "⏱  $(date +%H%Mhrs)"
echo ""
echo "Parsing parameters and running pre-checks:"
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"

# Parsing arguments
parse_parameters ${1}
echo "${CHECK_MARK}  parameters parsed from ${1}"

# Running pre-req checks
run_pre_checks
echo "${CHECK_MARK}  pre-checks done"
echo ""

# 1. EMR
${base_dir}/aws_delete_emr_cluster.sh ${param_file}
handle_exception $? $prefix "deleting EMR cluster" "Error deleting EMR cluster"

if [[ "$use_external_db" == "yes" && "$delete_external_db" == "yes" ]]
then
    echo "⏱  $(date +%H%Mhrs)"
    echo ""
    echo      "Deleting RDS for $prefix:"
    underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
    for ((i=1;i<=$prefix_length;i++))
    do
        underline=${underline}"▔"
    done
    echo ${underline}
    # 2. RDS
    db_id="${prefix}-emr-tpcds"
    aws rds delete-db-instance --db-instance-identifier ${db_id} --skip-final-snapshot  > /dev/null 2>&1

    wc=$(aws rds describe-db-instances --db-instance-identifier $db_id 2> /dev/null | jq -r .DBInstances[0].DBInstanceStatus | wc -l)

    spin='🌑🌒🌓🌔🌕🌖🌗🌘'
    while [ $wc -ne 0 ]
    do 
        status=$(aws rds describe-db-instances --db-instance-identifier $db_id 2> /dev/null | jq -r .DBInstances[0].DBInstanceStatus)
        i=$(( (i+1) %8 ))
        printf "\r${spin:$i:1}  $prefix: db status: $status                "
        sleep 5
        wc=$(aws rds describe-db-instances --db-instance-identifier $db_id 2> /dev/null | jq -r .DBInstances[0].DBInstanceStatus | wc -l)
    done
    printf "\r${CHECK_MARK}  $prefix: db status: not found"
    echo ""
   
    # 3. RDS network
    ${base_dir}/aws_delete_db_network.sh ${base_dir}/tmp/${prefix}-db-network.json
    handle_exception $? $prefix "deleting EMR cluster" "Error deleting EMR cluster"
    echo "${CHECK_MARK}  $prefix: RDS DB network deleted"
    echo ""
    echo "RDS assets deleted!"
    echo ""
fi 
# 4. AWS pre-reqs
${base_dir}/aws_delete_emr_pre_reqs.sh ${param_file}
handle_exception $? $prefix "deleting EMR AWS pre-requisites" "Error deleting AWS pre-requisites"

# # 3. Security Groups
# ${base_dir}/aws_delete_emr_sg.sh ${param_file}
# handle_exception $? $prefix "deleting EMR security groups" "Error deleting EMR security groups"

echo "⏱  $(date +%H%Mhrs)"
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ Finished to delete all emr things ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"