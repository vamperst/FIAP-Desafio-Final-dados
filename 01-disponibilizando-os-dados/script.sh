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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEsaCXVzLWVhc3QtMSJIMEYCIQDXz2G%2FkivkAcvikQAKmyY2NT18D5wfSvLB%2BXXpubP5ZwIhAP7xOrUJ4lCGTWbsIV4O1iLvAHzGixRkUiPDv%2FuBcjP%2BKssECMP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMMDM2MzQ1MzAzODE0Igwt%2F6z7EUvmXmr%2FVy8qnwSfFobhKuO3tL36z%2FRmY1Cexg4D8kPq%2FWsHlpGZFgaQL%2BFYQGFB3Sq3E0UhfkeJx%2Fzu2Ut0bw8w7USUO3S1j9XCHVhUqb3Hi%2FvqRi9m968EpwuO82AV2trzeuXiDGNwW%2BcXWF0zq728UWInnRDyxBvcsNw0HqGkQXD1RenHIyQ%2B3QfKeqM%2BVAgbGibpLOo%2FVlH%2FllobFdDTagOAhn9J1k%2FyWDlaYUXg4MXTA4X0Yd%2FgEsYX5lrKP65j7AwdxkvJCK48js4KfaSsr%2FbRLwSDF1QchoE%2FEJ%2B1xpeIZjLDSk72YiCvLbvL05LH4WL6SgCejnWJWJiLLiCb3akNMaeqFAtJwYcC%2F7%2B%2FP7WMu1F4eoECeWYkugiupMx1NtZI3FZQG8BA8mxKB%2BrZ4Q2YqKxh%2BeLH%2FJ5FIH4Sz9Srz54nf0m60DfQKlZ3bKKw%2FKNKQ7QO6nABjwvVIlnaMN3d6Kp5Ql9SaTspNb%2FHNb%2F5B%2F9bWy9zEI77sUA1RDRUDOrrr6os%2BBKVqK5vKwoP2vwnCnt8HWhbf2ZGregBFM26N1QtdATocqhRJdGFANf4vDVNmNi3lwnMmDnfE7AQOHiuqvFw0EywkPGg9kd2m1kXDfH1g312amHlTAcF%2Bv23891QVsDtYr4hp55u58Pr9ZvMDcWKJJ5C3qpuJ%2FdQo0dxlU7yXW1a6nbM7Rr7B656bhwiOuQmIECXZ4srVa76h%2BbCpPHafjUwlqnlvwY6xAJcZ6BEshgbwPpk8ggNhmEgyp5o1432QM1%2Bf8aLXgoYuT0gW14uPpzcj5VwzZ9xs7gRynKzHotNpJGYVyCXyx%2FpBXxinD0fKd2Oe82rV0Z1aCc9ikr%2BZoJto64do%2BqY2qeQel9NTNCx%2FdL5327CfPO9oIKDyBH9My3ptZCNOMbJ9avTdEeZTUq2%2F9VZC0wR7CfG2MWNcyu4vlX1Dk85mSp%2BC77TMABJ%2F0i5tJD63JJwT41pM24YkNt5wdAXmydHkIMaEYh%2FyuWphTSbMpn68GJKTNlaIZ6c5mFXKGETWtjz3c4xDUlQTw6tkhzeM3tRXz0VMbLN0jC%2BLLkdpGXA3L5GZXLZAmm3syGxDGMFZH1vmoV6Bo8qm0xPGAzQ4DhvVJxIUof3xqPWfpOATw3hb4C3aDFRJPlwkoOm8BVzRSFRNcLFmq4%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDBDVQ54VT%2F20250411%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250411T182016Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=cf7f23e5ae4e84a61450a55ff7f0bd341d966b3ea22626b4eb31c1bc39915bed"
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
    else
        echo "Erro ao executar o crawler. Status: $STATUS"
        exit 1
    fi
done
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
# Script finalizado
echo "Script finalizado com sucesso."