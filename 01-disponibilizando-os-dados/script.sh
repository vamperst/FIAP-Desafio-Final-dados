#! /bin/bash

# Script para criar o bucket no S3
# e fazer o upload do arquivo de configuração
# do Terraform

# atribuindo primeira entrada do script para variável GROUP_NAME
GROUP_NAME=$1
echo "Grupo: $GROUP_NAME"
# Verificando se o nome do grupo foi fornecido
if [ -z "$GROUP_NAME" ]; then
    echo "Uso: $0 <nome_do_grupo>"
    exit 1
fi


# Definindo variáveis
BUCKET_NAME="grupo-fiap-anime-$GROUP_NAME"
DATASET_PATH_S3="dados-brutos/"
REGION="us-east-1"
FILE_PATH="caminho/para/seu/arquivo.tf"
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEE0aCXVzLWVhc3QtMSJIMEYCIQD%2FrFqcU0MW00ZUIRsAdSAyJeL%2B3Habe%2BbfLOYYI1fMrgIhAL3gWKL0HGD1Ypdod2neCayQzVUGgTR%2Fo%2BnHAkTkewu%2FKsIECBYQABoMMDM2MzQ1MzAzODE0IgxdSGtzrMZYG%2FAhtIwqnwQ%2Baw9JfLwRgWX6o80cDq5338dx1PJ4l9cSu1N4c2DGghpRBThI0BDC1WUgpF06FuX7neLuUo880RzcnVkxcGeqAP41AdRTGJl5dZEss7Y%2FX%2FWJMZRJU8PSiffXeK7bIlww%2B2IVxdEEvtRcm1sgzWIIg3cU73t%2BzyQs%2FAIm%2FJZgcc5yszSRsd5wYrPTgfnMULhgGLRDP6UrNWwW3YxvmHcq%2BGqyiVL8%2FSAK%2BA7fExnnyao6TS7vLfQMEpyfROoizENsTEhNMJ%2F0IaqcrPEB7uGPHdiKRrENUT9xbfB9DZk%2BC14PEJIiRAJD4PaJYVCXHAqQOqwTff7GTa87iB61v%2BIuTRQv0SKs5gYj8BR5IxQ90pP8RHBFlqpqaL94IAkZSvvG1ARHibHApNWEf849V4LieyVK6AzMBq9cOds8RLMBUZD6yNoLrJ5oOTWa%2FRkzjP0x1HpCS3lbmN0SH2PiAKrFDwWWh8lcpWinTEbwG32IUNB7bUKPtiAPfkjprog3%2FDvQP%2FA4STBa9cavevDTKmztDXXF1PTJ6UtkCaJOUgxsEMy8h9yw%2FUsNppg%2FyGnQViangSnYFYIRz0k3B%2FUEb79Va0zf2slF7zP8m94tLnRpnI%2BjF3sDZ3qEIQbxWw3l4f6qow0Wwjhzoj88LhJmOu76mWnRFZYgcHu4l5CAvyuJVRwa12UHNGZn93U%2BX4Qau4qiG1aNdVtspT9Z2O%2BKnpAwmoHHwQY6xAKBN%2BvA9LL%2F1KtGeK93c5kVwHfOZ2Q%2Baj1R%2FB9zXtvYd9t45RenbKF0EXb3kfwDuiVZvNrZjNj8xzFQu3Zevf9nEeBc5A4dav%2B3Bq0IxEMiCSxLJQWvksyEmKYDWfPRTwKJAUNU5KlYpCS1XklQQkAkGPdmO8R25N6QVhmbgzVF4HKBJ4Zrnjcbx0LgKIsOMdYxZTwTCSoKnmPoWb6gQCwcqkkeOjhcccPnaetQ0eZzwYIOHeMsqn3ORr1wYYeWxVmEg5QA4OUOVIPbTJeaLd6LEtDsjk3%2BBiWRs94x7wU5CVjC8%2FMEmE5BNmmh98zCh7S8Mx7LHAIBiBiCBkg22Tp2dwSRLpz4VA6DOeitdUvr3O35rI0aXOL69Uo5Tb2bYxIJBrWUJLodfjVoAmRBMcVUnnJ7%2BXsDloZwNZuJcgZ5CeIGxgw%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDN7PCSBGC%2F20250524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250524T125110Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=e1bd579390daf61a4750c7cc384352bb8bbf0417e277d06b1a44b0d530853816"
CRAWLER_NAME="animes_crawler"



# Criando o bucket no S3 caso não exista
# Verificando se o bucket já existe
EXISTING_BUCKET=$(aws s3api list-buckets --query "Buckets[?Name=='$BUCKET_NAME'].Name" --output text)
if [ "$EXISTING_BUCKET" == "$BUCKET_NAME" ]; then
    echo "Bucket $BUCKET_NAME já existe."
else
    echo "Bucket $BUCKET_NAME não existe. Criando o bucket..."
    aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION
    # Verificando se o bucket foi criado com sucesso
    if [ $? -eq 0 ]; then
        echo "Bucket $BUCKET_NAME criado com sucesso na região $REGION."
    else
        echo "Erro ao criar o bucket $BUCKET_NAME."
        exit 1
    fi
fi

# verificar se terraform está instalado
if ! command -v terraform &> /dev/null
then
    echo "Terraform não encontrado. Instalando..."
    # Baixando e instalando o Terraform
    bash install_terraform_cloudshell.sh
else
    echo "Terraform já está instalado."
fi


cd Colocando-dados-no-S3/

zip lambda_unzip_s3.zip lambda_function.py

terraform init
echo "Terraform inicializado com sucesso."
# criando o tfvars
echo "Criando o arquivo de variáveis..."
rm -f terraform.tfvars
cat <<EOL > terraform.tfvars
s3_bucket_name = "$BUCKET_NAME"
signed_zip_url = "$LINK_TO_DATASET"
EOL

echo "Terraform rodando apply..."
terraform plan --var="s3_bucket_name=$BUCKET_NAME" --var="signed_zip_url=$LINK_TO_DATASET"

echo "Terraform rodando apply..."
terraform apply -auto-approve --var="s3_bucket_name=$BUCKET_NAME" --var="signed_zip_url=$LINK_TO_DATASET"
# Verificando se o Terraform foi executado com sucesso
if [ $? -eq 0 ]; then
    echo "Terraform do lambda executado com sucesso."
else
    echo "Erro ao executar o Terraform do lambda."
    exit 1
fi

rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup



cd ../Crawler/
# Rodar Terraform
terraform init
echo "Terraform inicializado com sucesso."
# criando o tfvars
echo "Criando o arquivo de variáveis..."
rm -f terraform.tfvars
cat <<EOL > terraform.tfvars
s3_bucket_name = "$BUCKET_NAME"
s3_data_path = "$DATASET_PATH_S3"
EOL

terraform plan --var="s3_bucket_name=$BUCKET_NAME" --var="s3_data_path=$DATASET_PATH_S3"
echo "Terraform rodando apply..."

terraform apply -auto-approve --var="s3_bucket_name=$BUCKET_NAME" --var="s3_data_path=$DATASET_PATH_S3"
# Verificando se o Terraform foi executado com sucesso
if [ $? -eq 0 ]; then
    echo "Terraform executado com sucesso."
else
    echo "Erro ao executar o Terraform."
    exit 1
fi

#executando o crawler
aws glue start-crawler --name $CRAWLER_NAME
# Verificando se o crawler foi iniciado com sucesso
if [ $? -eq 0 ]; then
    echo "Crawler iniciado com sucesso."
else
    echo "Erro ao iniciar o crawler."
    exit 1
fi
# Verificando o status do crawler
while true; do
    STATUS=$(aws glue get-crawler --name $CRAWLER_NAME --query 'Crawler.State' --output text)
    if [ "$STATUS" == "READY" ]; then
        echo "Crawler finalizado com sucesso."
        break
    elif [ "$STATUS" == "RUNNING" ]; then
        echo "Crawler ainda está em execução..."
        sleep 30
    elif [ "$STATUS" == "STOPPING" ]; then
        echo "Crawler ainda está em execução e parando..."
        sleep 30
    else
        echo "Erro ao executar o crawler. Status: $STATUS"
        exit 1
    fi
done
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

echo "Esperando 30 segundos para o Glue criar as tabelas..."
sleep 30

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

if [ "$BUCKET_NAME" == "None" ]; then
    echo "No bucket found with prefix '$PREFIX'. Exiting."
    exit 1
fi
echo "Using bucket: ${BUCKET_NAME}"

# Set Athena output location using the found bucket
OUTPUT_LOCATION="s3://${BUCKET_NAME}/queries_athena/"

# Create Athena View
QUERY="CREATE OR REPLACE VIEW \"user_score_2023_animes_data_2023_user_details_2023\" AS 
SELECT
  a.*
, us.user_id
, us.anime_title
, us.rating user_rating
, ud.*
, (CAST(YEAR(current_date) AS INT) - CAST(REGEXP_EXTRACT(birthday, '^(\d{4})', 1) AS INT)) user_age
,  from_unixtime(aired_from / 1000000000) AS aired_from_convertida, from_unixtime(aired_to / 1000000000) AS aired_to_convertida
FROM
  ((users_score_2023 us
LEFT JOIN anime_dataset_2023 a ON (a.anime_id = us.anime_id))
LEFT JOIN users_details_2023 ud ON (us.user_id = ud.mal_id)) LIMIT 10000"

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


# Script finalizado
echo "Script finalizado com sucesso."
