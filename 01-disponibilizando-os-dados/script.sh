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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJIMEYCIQDhj8Un%2BZY%2BCwx2LBaOC2BX5rTkEuUX1PaTR7Fw9BKFXQIhAN37ESnQluVYxdlfxdQlY2yI0awgd18IZKcTwbushSX6KssECNT%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMMDM2MzQ1MzAzODE0IgzF0mZRk%2BdWTjRpjOYqnwTKMNj0Jo6TYnpZRRoAdVM5TnIXRgWd8lecriqcP7lFsy1FW6QNYaCbKftrbXiERUcRYSsEM%2FMhPMcclfY1w0%2FD5nTl2lEB4%2B3lSjLVIMx5xfJjQTgkdU2RHCdy38ar3iruJsLfPTPosOJy%2BwYDBnBAPEdaweI3KWf8cX626TTEesnyY%2Fkd5CPT1ZTzIGHoFkb9ls5a6itO1YbhWi2AYX1NHGX8JwiVkLBg%2FQiE9n9q%2BdSp9kYBXgg660%2ByV%2F3G%2BhTyy4w4bT%2Bjx14xzURHZS%2BfXuqywawFYb53XI%2F7rqFI7cfwUeoaV9MJGdMMOQPgTsJrzK3jaTz3YQaC9iYy%2FFb6skQ8b245Wcbu2RkyAVWeQPGIPhU2t41LeR1%2F5JuTWe8vhmgP4NTsLMJdmqAlfs76DOKTBqYpu2mRbEhuVRxijJHQkcnAlbp0s23Hd1Zvn9HDxTL%2FJolEs5cJgVbDc9qJ7n%2BWYXMOxMr7Y3Y1BRV2rxycCIs2EfhqVYWBwlZXmQWiLTc2h7bS75MVEW6FM4NPogJ%2F%2Ft0la86xY7ZnICqhyfUaHi2dLRUklqmwGvnMjsPdfLnrpSG66cF%2F1V05W4XcxsuxF3vS4BwwAzCeR2uD9KH5eUOdv86UIJcLek4EO6dq8%2BsBr9IcIuH0GH3XD92t0OvDaMDPsT3vsNVCDKOgfabvY3JVOqxcv%2FWakeDceh%2F1ZMj%2Br2hIXOD2hJvghK8w7IHpvwY6xALB6lofxJJYV0joSOPU9oEd7hVxON1MPSRvSPtuh848KzBwNlzDcCtjxqJj1rLiMSWEzBv9Z0x09mEptojCsoQDrBRJCbHTDBqJQ9lu38SZ91eKxoa0yvV9q0hqtzp2BxAST3eFYsIynprh1sn%2BG0Q4nkgPJzbiYk6DaZzy5wNSK0IjfSl29gaoOPvh4tzJxUxRjA3%2BQa%2B8pf2q9FJkmZY1%2FggMj7hq18RRJPer1Eo6GXo77JR7brtcUA%2F43vmNdM4a4MICnD%2BkaHIz71zuO12Wr8ei3SSmiAv9UlaOLm%2BBeB52qoP%2FTMqdv1a1KjMmUoJl4RYYJp2tLDApVvT8wrKgkw9ZBYa8qZfuhJi%2BV7iUI4w%2FcfK9Flg9TR7dR3O4YZPTrvzbgM4aaij7qowp4WjhaIeHAvWOtkTq%2FYw6Mw%2BXEQqyUFM%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDKALR6A2Y%2F20250412%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250412T103132Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=5fff0b7fc14e5a84a52bc2556d190d1b3cd384d8e36c84bacf481c7eb25b7e5a"
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
