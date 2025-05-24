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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEEaCXVzLWVhc3QtMSJGMEQCIGP2LaFLQT9BpsCnqCy6w%2Bd3PDPQi%2FDI39mDu%2Fh2walPAiALAaxDYoHUJNawrY9zyQ1lKtbLmCpms0vw8y17dnyU4yrLBAj6%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDAzNjM0NTMwMzgxNCIMcXrqRxWFzM6Mq6e0Kp8En7VSo%2FIUCJOmhiXx4OE7G8XI5LRCI2WrWucW3G3rKWY20C6H%2Fl1HTfLaRLii8a0yhB3roIyBvBAFe9b2KyKQ6luIDqxnIOxXTmo%2BAFGO1LXH5xSMiqnZfozl3HJCUm%2F6ci10CAn6ErDXSBrNK95TEF2sQrIumBM9TNudzolDe8yr4q%2BfQwfEkSPjVSkumk1x0tYUJsH%2FK%2FlW0ATUZg4BdxOhWQtWc7tiX0ukFQ5ltVX8hq%2Fa6%2BnQAjHSzqmD9BhyNYwoO%2FPBqhjSlQbmotmCDzvOqvdjW3PhdeqAdUAIPCg4dmWHRNplzkJFCHpfpTVMbF3t12djevov9m8AFxbguIxdVB9WSHAoG2AoH024cqTPtVExv5K7py%2FZ7NBhpXJFPKzT1H1YLp7ks8zIAy046gAhaIbAZZg8sJZmgQ4euQv0VBojjcteQfoyYhQjTnUGt7ka%2FhTitxg25dAoVr7ahF7JFRvywvfwGgMXJE%2FeAnKmmZOCITj8nqBsrR9mnM1CjUuP4S3ypvZaWnRjBTg3YXFuNq1O1GYQ8TUUDtFBAnYkJl4GQ72UCk8SOBXOznxjtIW7SmdyyKrKcOrZ%2B2YWg51nZxXLGCOHy2R9I7KyP5h57S6X6UAFldOER9%2Fy5CjTb%2FcYLFj16CaWRh9mdy%2F4d1Anhv2U3OiSs0zxIsfFeEW1HOj0ckx%2BIZZd%2FcN9n1y0yCOpkjb0Th%2BH%2Bdyu20P5MP6DxMEGOsYCrUgAuD3yE51e%2BilSlPzvPLnSTQ%2Bwdng7D3Zxkj4yjzRdj%2FXqMKzM3j6tT0I%2FLLTOtXixC4U44cbOLwISafKkApdSZd3U4xEurJaWEY1ru%2BkQ26CPmYHKOQUY0Wyp7%2BvGoYCiGuVKIBKsWB94rKm4ynAvsFbiP1OrVAfT6nEYs62P8%2BTDHf7Ajoi2c25TSHyiKViCbgMDZHVyTv6Y2kCvPJah8MO%2BMICKfnFjEOl%2B0UPx%2BrmVHHF2gmpq2NsE7MjmTGWSFMpWZW9Ay30oV07hmbgbhRJOJtZDMUbq7aOMeKJMy51%2Fob4qxNfljCpQQR%2BUHl6ZJuW6nZeFhyyj8HBI2NmzgHBri6q5WorKbSMIU3Dg3MdPYRMfQRNgTuwsxM7N4v%2FXz%2FDU59B1X3v6FNAKF7%2FTBUfPqV09J4sB2L5lzKWDrwfU8H4%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDP2XYD4VX%2F20250524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250524T003917Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=fe339a31e3ec5fd7c1b81f4d23ef539dd135909bb8fc4cc6d1e44eaa4380d14a"
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


# Script finalizado
echo "Script finalizado com sucesso."
