# EMR TCP-DS Benchmark

This workshop repository provides tools to easily run a TCP-DS benchmark on AWS.
It allows the folowing:
* Dynamic creation/deletion of an EMR 6.0 cluster
* Automated setup of TCP-DS for this cluster
* Download & generate CSV from queries result
* Download tez & simulate hive logs for WXM upload


# Pre-Requisites

* AWS CLI with access to cu_manowar_pref_dw
* Bucket s3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/ with 10TB data
* jq
* git


# EMR setup

## Creation
```
aws_create_all_emr_things.sh <parameter_file> (see emr_parameters.json example)
```

## Deletion
```
aws_delete_all_emr_things.sh <emr_parameter_file>
```

# Results

## Queries

### Download queries
```
download_queries.sh <emr_master_host>
```

### Generate csv
```
generate_query_stats.sh <date_folder>
```


## Logs for WXM

### Download Tez Logs
```
download_logs.sh <emr_master_host>
```

### Simulate Hive Logs
```
simulate_logs.sh <date_folder>
```


# Authors

**Paul Vidal** - *Initial work* - [LinkedIn](https://www.linkedin.com/in/paulvid/)