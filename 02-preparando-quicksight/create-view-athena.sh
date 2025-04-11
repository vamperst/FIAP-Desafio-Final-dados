#!/bin/bash

# Get AWS Account ID and Region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="us-east-1"

# Set variables
DATABASE_NAME="animes_db"
WORKGROUP_NAME="primary"
CATALOG_NAME="AwsDataCatalog"
QUICKSIGHT_DATASET_NAME="user_score_2023_animes_data_2023_user_details_2023"

echo "Using AWS Account ID: ${AWS_ACCOUNT_ID}"
echo "Using Region: ${REGION}"

# Get the first bucket name from the account
PREFIX="grupo-fiap-anime-"
BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, \⁠ ${PREFIX}\ ⁠)].Name | [0]" --output text)

if [ "$BUCKET_NAME" == "None" ]; then
    echo "No bucket found with prefix '$PREFIX'. Exiting."
    exit 1
fi
echo "Using bucket: ${BUCKET_NAME}"

# Set Athena output location using the found bucket
OUTPUT_LOCATION="s3://${BUCKET_NAME}/athena-results/"

# Create Athena View
QUERY="CREATE OR REPLACE VIEW \"user_score_2023_animes_data_2023_user_details_2023\" AS 
SELECT
  a.*
, us.user_id
, us.anime_title
, us.rating user_rating
, ud.*
, (CAST(YEAR(current_date) AS INT) - CAST(REGEXP_EXTRACT(birthday, '^(\d{4})', 1) AS INT)) user_age
FROM
  ((users_score_2023 us
LEFT JOIN anime_dataset_2023 a ON (a.anime_id = us.anime_id))
LEFT JOIN users_details_2023 ud ON (us.user_id = ud.mal_id))"

# Start Athena query execution
QUERY_EXECUTION_ID=$(aws athena start-query-execution \
    --query-string "$QUERY" \
    --query-execution-context Database="${DATABASE_NAME}",Catalog="${CATALOG_NAME}" \
    --work-group "${WORKGROUP_NAME}" \
    --result-configuration "OutputLocation=${OUTPUT_LOCATION}" \
    --region "${REGION}" \
    --output text)

echo "Started Athena query execution with ID: ${QUERY_EXECUTION_ID}"

# Wait for query to complete
while true; do
    QUERY_STATUS=$(aws athena get-query-execution \
        --query-execution-id "${QUERY_EXECUTION_ID}" \
        --region "${REGION}" \
        --output text \
        --query "QueryExecution.Status.State")
    
    if [ "${QUERY_STATUS}" = "SUCCEEDED" ]; then
        echo "View creation completed successfully"
        break
    elif [ "${QUERY_STATUS}" = "FAILED" ] || [ "${QUERY_STATUS}" = "CANCELLED" ]; then
        echo "View creation failed or was cancelled"
        exit 1
    fi
    
    echo "Waiting for view creation to complete..."
    sleep 5
done
