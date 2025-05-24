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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEsaCXVzLWVhc3QtMSJHMEUCIHg7MHhyURTJ4csUFnUGRo02FInPBT2EHUz8O91zkqZmAiEAwypDkwRuJnA9IcYgc%2BCsFqLvcP8DAde1kILtQpbCPEcqwgQIExAAGgwwMzYzNDUzMDM4MTQiDEkYRaZ0y7phEvKZXSqfBDL7Wlc%2B6snkLCjF63ATdfhJLo18UDNZc%2BIQOS1%2FzLJhJP1EgCnaOLHLbpvUlKdd1%2F6bTz83P8lTvN8rnZkDxHrbiLkP4JEGDjVACkR9vrAp61F%2BK90XZlDwWB0%2BODJWTh6etRv5YETpgw0zRw6eGbz4T5b6cUaEu%2FRlM8eqsdegvmsp04XVCObsNP8Y46fWeciz3sGCeaiXC29Qz4OrU4EDMLzJ3ZSu0VgY%2Bib0BD%2Ba90yBGTRClYIZrB9uvx4W13A4ALps6zod6VYFq7tlqzzJEfUHI3gy%2FGNmUZo7Ypu9sDp159tdHJtt2uWN5SBghfal1Mnw2CQkzO7d5XncHoOp4Ua7%2BEsQ0bChAQ8H3XuQls6L5XkmPcW1TLRvRkr43gfSipkA1PBKKe%2FFFuaQsDVwpUWlgBVs5cQDJV0d7caFWDNunBxaOHyxD5qGb2G9pDAk92hdC2Foirm6te2WUy7fbn2QJDbWSPAoArY9CcA6FvMpohbyBp88hBECyCtYS3rgvaHHDJodezggVgO%2B0dp6RdRjjyuZGnGaVNyeaNyk6WAwl7x%2F9%2FJ6CxVs9gIDmTOuD6jkrUs99WX9RWfV7SKp%2FsunPWxRs7E6FmHzjUMtePn2am52d%2FYugHaP2szhj%2BBxE%2F5A9dMkpXUGM8ux%2BYh6ohs8MStCU0LKefk%2FDsRx%2FDNcwMp8wXYqFQ60dVBaVDvvyck9i6tV7m9tZHsGDDD%2Bg8TBBjrFAtSgG%2BG2UhpGJiyfDvcuhsx50q%2BCVnZi5D6kCnVA5ONEV4xmDOmgHczrg%2FgZsGqR7NrpYYF1vq6FywiXbpfIJmbHb2hvRs2Tt6l00yji922kBm8WFnTIFHI54fvm5qFOqbBgbaLdA%2FgrAFviUaixQNGwK7ElbyWFiyazqgjbra32XvfuXhxRzUjHDeSNPaxwva4XCoWjIY7HC89l1JXOyKjRu%2Fh4gcTWV%2BgsLrpSdAVoI3I1UKqpz%2F4GDo5xk%2FbBDNJXhEI7A2zAhpWC97I8Yd4ckaBSs7Fsasa5DAj0Q2DdKVHDNXO9YhXKSZs82cF1sHdbUGjICUcFBeZYTluTTQhM7Ic5qctkioVMI1sAmdsYPFgpsUELbCVDz0Qr9FBR4VCqASXTG3H4w29L%2FqDy%2FaH7%2BCCkpRuRap%2FcWLoNMGrBwXT0B00%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDFOWV6XFR%2F20250524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250524T101045Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=11553c065d822a11d3cdd9726ba5a856e524ba51cb76bd078e78615055617740"
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
