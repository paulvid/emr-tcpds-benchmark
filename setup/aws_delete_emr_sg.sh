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
echo "Deleting EMR network for $prefix:"
underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
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

        master_group=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Ec2InstanceAttributes.EmrManagedMasterSecurityGroup)
        slave_group=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Ec2InstanceAttributes.EmrManagedSlaveSecurityGroup)

        aws ec2 revoke-security-group-ingress --group-id $slave_group --source-group $master_group --protocol tcp --port 0-65535
        aws ec2 revoke-security-group-ingress --group-id $slave_group --source-group $master_group --protocol udp --port 0-65535
        aws ec2 revoke-security-group-ingress --group-id $slave_group --source-group $master_group --protocol all --port all
        aws ec2 revoke-security-group-ingress --group-id $master_group --source-group $slave_group --protocol tcp --port 0-65535
        aws ec2 revoke-security-group-ingress --group-id $master_group --source-group $slave_group --protocol udp --port 0-65535
        aws ec2 revoke-security-group-ingress --group-id $master_group --source-group $slave_group --protocol icmp --port all

        aws ec2 delete-security-group  --group-id $master_group
        aws ec2 delete-security-group  --group-id $slave_group

       
    fi 
    echo "${CHECK_MARK}  $prefix: network deleted for cluster id: $cluster_id "
done


echo ""
echo "EMR network deleted for $prefix!"
echo ""