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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEMaCXVzLWVhc3QtMSJGMEQCID07Z8KHmhgWsuNsxPc8LAY1a3IKOUUCz4qWBdBLbp5JAiB8xhpxIRYtihWDXzop8X6Qat%2F0pmtQAkuT2yxmqRmTNSrLBAj8%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDAzNjM0NTMwMzgxNCIMdHK4KqGKh186BArGKp8EhpRXX%2FF9HiYIxz0N%2B%2F4CMfLhef1YZH%2Fk1vLGXmn%2FopiJx4tCxlNgm%2FHzHoZuXlwvJY3t3pftC84O47YG6TpuxHNyXVsDa6YkoXcz2f%2F8rB55k9sYx9E%2BLNgw03i%2F8hBdqsekd0vEReTQ4S0ueEiUpW1V%2B3u%2FTD9MkPhtKe3xMYkHUw%2FfOSRYNvtcRc1hFStLyWNq0m5XSbo%2FhJjMPdygNu%2F2sFVRQVFdvhp5jV0YDASo9SMQhAITHvdmKRkHn1lUfyD2BviK7RYC10e0wxa6y3DK2Olg50i9UnBqJMCwG6s%2F1mg7asJ0OA%2BDOv0eTR3GYYWW4hrg2lNNCkSzdYpQLJxUBMpiQQvIgTvc3bqzg3FGLbNK8JuMsm%2B8DltrFAVe9jzP7jjbldwYSRrYBy2BNs3J3PbqyV9n%2FWsVM0ZuEh9%2BUm%2BmUrlGPT7oHbvbofk%2Bki2lwBbRjRG3IQGmGj45YgZI4YW0T9lx%2B5OthBMOZqeb4%2F0JdSh%2FHCv28vKnph4tLFQhE0ijxW2B8RtU5B1ZSrCf9z6z%2BbMmJ%2BgXmzfLmGIuI1MsSdFbOWWwq7d30KY4NKA4%2FaruOe4AL9%2BrTnrJ6ZAgpETwg%2Bq3XnLVWXqQmtqdktgT42LGDMyzh3kvjsdMKP%2FpBMSfJjywaNQ2UfRJwGdO91a4ngiGWY5LA9N9JS3zLA1IGa3SK8uzVzePGyCD5hTwcyE2XnBq9hfr0Uc5MP6DxMEGOsYCb1yM2PsPvQ5Q0WI%2BeDaAe5xKtSh4dFiQZqItPVlPdoiw3dMmMgRM8DeeNLLyftj3afD4GebAITj2FHm5C7%2FQZJ1C%2FIUH80dPxjD7XaUrCPEFS42Hmg%2FSpdANRWTnrhaKVK%2FU447nRaO%2BthxhuomiTj0gjZfj51G5kuVL5jTNuNA%2FeLxwUNPBPURLBLffXTitDVcaWDVA9aoTvyeV2CRX7ffdA3HFRsaeHYIxw2JTvyvIO9f0mo1DuEj2cI5K3HkRdFrcAzZXyJ1cZBFBbdNSxhO2USM6767kW0hdnchKKkj7tfEcYoAbXHugvIuVGkyxpgSeJSfC1dKzUy1xuOCxpGRvd6KKLHMaunxbeNP%2FYOTsb%2Bg4byhbKBi1q5mxBDyua7aefdrZFqhStap53Bjr0%2BwGP1Gcnds2CyExl8GFzuDApopgf28%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDKDMMBCCJ%2F20250524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250524T030323Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=9f9ddcef421b1e936427388b303c066dd48093fa858def51712b7a0bacb18951"
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
