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
echo "┃ Starting to create all emr things ┃"
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

# AWS pre-reqs
${base_dir}/aws_create_emr_pre_reqs.sh ${param_file}
handle_exception $? $prefix "creating EMR AWS pre-requisites" "Error creating pre-requisites"

# RDS
if [[ "$use_external_db" == "yes" ]]
then
    echo "⏱  $(date +%H%Mhrs)"
    echo ""
    echo      "Creating RDS for $prefix:"
    underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
    for ((i=1;i<=$prefix_length;i++))
    do
        underline=${underline}"▔"
    done
    echo ${underline}

    db_id="${prefix}-emr-tpcds"
    wc=$(aws rds describe-db-instances --db-instance-identifier $db_id 2> /dev/null | wc -l)
    if [ $wc -gt 0 ]
    then
        echo "${ALREADY_DONE}  $prefix: $db_id already created"
    else
        create_network=$($base_dir/aws_create_db_network.sh ${prefix} ${region})
        handle_exception $? $prefix "creating AWS DB network" "Error creating AWS DB network"
        echo $create_network > ${base_dir}/tmp/$prefix-db-network.json
        echo "${CHECK_MARK}  $prefix: RDS DB network created"
        sg_id=$(echo $create_network | jq -r .GroupId)
        db_subnet_group=$(echo $create_network | jq -r .DBSubnetGroupName)

        create_db=$($base_dir/aws_create_mariadb_rds.sh $prefix $sg_id $db_subnet_group)
        db_id=$(echo $create_db | jq -r .DBInstance.DBInstanceIdentifier)

        status=$(aws rds describe-db-instances --db-instance-identifier $db_id | jq -r .DBInstances[0].DBInstanceStatus)

        spin='🌑🌒🌓🌔🌕🌖🌗🌘'
        while [ "$status" != "available" ]
        do 
            i=$(( (i+1) %8 ))
            printf "\r${spin:$i:1}  $prefix: db status: $status             "
            sleep 5
            status=$(aws rds describe-db-instances --db-instance-identifier $db_id | jq -r .DBInstances[0].DBInstanceStatus)
        done
        printf "\r${CHECK_MARK}  $prefix: db status: $status                "
        echo ""
    fi
    host=$(aws rds describe-db-instances --db-instance-identifier $db_id | jq -r .DBInstances[0].Endpoint.Address)
    port=$(aws rds describe-db-instances --db-instance-identifier $db_id | jq -r .DBInstances[0].Endpoint.Port)
    ip=$(nslookup $host | awk '/^Address: / { print $2 }')

    
    sed 's|<DB_USER>|admin|g;s|<DB_PASSWORD>|emrtpcds|g;s|<DB_URL>|'${host}'|g;s|<DB_PORT>|'${port}'|g' $base_dir/emr_configurations_external_db.json > $base_dir/tmp/${prefix}_emr_configurations.json
   
fi


# EMR
${base_dir}/aws_create_emr_cluster.sh ${param_file} 
handle_exception $? $prefix "creating EMR cluster" "Error Creating EMR cluster"


echo "⏱  $(date +%H%Mhrs)"
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ Finished to create all emr things ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"