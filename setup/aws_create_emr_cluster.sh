#!/bin/bash 
source $(cd $(dirname $0); pwd -L)/common.sh
BASE_DIR=$(cd $(dirname $0); pwd -L)

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
echo "Creating EMR cluster for $prefix:"
underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
for ((i=1;i<=$prefix_length;i++))
do
    underline=${underline}"▔"
done
echo ${underline}

cluster_name=$prefix-emr-cluster

if [[ $emr_version == "emr-6.1.0" ]] 
then

    if [[ "$use_external_db" == "yes" ]]
    then
        conf_file=$BASE_DIR/tmp/${prefix}_emr_configurations.json
    else
        conf_file=$BASE_DIR/emr_configurations.json
    fi
    result=$(aws emr create-cluster --applications Name=Hive Name=Tez Name=ZooKeeper --ec2-attributes '{"KeyName":"'$key'","InstanceProfile":"'$prefix'-emr-ec2-default-role"}' --service-role $prefix-emr-default-role --enable-debugging --release-label $emr_version --log-uri 's3n://'$prefix'-emr-bucket/elasticmapreduce/' --name $cluster_name --instance-groups '[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":64,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.2xlarge","Name":"Master Instance Group"},{"InstanceCount": '$worker_count',"InstanceGroupType":"CORE","InstanceType":"'$worker_type'","Name":"Core Instance Group"}]' --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region $region --configurations file://$conf_file --bootstrap-actions '[{"Path":"s3://aws-bigdata-blog/artifacts/hive-acid-blog/make_bucketing_optional_for_hive_acid_EMR_6_1.sh","Name":"Set bucketing as optional for Hive ACID"}]')
    handle_exception $? $prefix "creating EMR cluster" "$result"
    
else
    echo "Version $emr_version not supported" >&2
    exit 1
fi

cluster_id=$(echo $result | jq -r .ClusterId)
cluster_status=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Status.State)

spin='🌑🌒🌓🌔🌕🌖🌗🌘'
while [ "$cluster_status" != "WAITING" ]
do 
    i=$(( (i+1) %8 ))
    printf "\r${spin:$i:1}  $prefix: $cluster_name emr cluster status: $cluster_status                           "
    sleep 2
    cluster_status=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.Status.State)
done

printf "\r${CHECK_MARK}  $prefix: $cluster_name emr cluster status: $cluster_status                            "
echo ""

public_host=$(aws emr describe-cluster --cluster-id $cluster_id | jq -r .Cluster.MasterPublicDnsName)
printf "\r${CHECK_MARK}  $prefix: $cluster_name emr master host: $public_host                            "
echo ""

result=$(${base_dir}/data/scripts/aws_setup_worldwidebank.sh $public_host $prefix 2>&1 > /dev/null)
handle_exception $? $prefix "Uploading wwbank data" "$result"
printf "\r${CHECK_MARK}  $prefix: wwbank data uploaded                            "
echo ""


result=$(${base_dir}/data/scripts/aws_setup_tpcds.sh $public_host $base_dir 2>&1 > /dev/null)
handle_exception $? $prefix "Building up tcpds" "$result"
printf "\r${CHECK_MARK}  $prefix: tcpds built                            "
echo ""

echo ""
echo "EMR cluster created for $prefix!"
echo ""