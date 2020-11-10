function display_usage() {
  echo "Usage: $(basename "$0") <public_host> <prefix> [--help or -h]"
}

if [[ ( $1 == "--help") ||  $1 == "-h" || $# != 2 ]]; then
  display_usage
  exit 0
fi

MASTER_HOST=$1
PREFIX=$2

# NOTE: Change the location of your worldwide bank folder if need be
git clone https://github.com/paulvid/datasets.git

aws s3 sync ./datasets/worldwidebank/ s3://${PREFIX}-emr-bucket/worldwidebank/
cat ./datasets/worldwidebank/create_worldwidebank_emr.sql | sed s/{PREFIX}-cdp/"${PREFIX}"-emr/g > ${PREFIX}_sql_tmp

scp -i ~/.ssh/field.pem ${PREFIX}_sql_tmp hadoop@${MASTER_HOST}:/tmp/create_worldwidebank.sql
ssh -i ~/.ssh/field.pem hadoop@${MASTER_HOST} hive -f /tmp/create_worldwidebank.sql

rm ${PREFIX}_sql_tmp
rm -rf datasets/