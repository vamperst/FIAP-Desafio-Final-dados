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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjELj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJIMEYCIQCAqh2mxYxaIyyn2Mf6j8zBl%2B3%2BZmMTsi61RMKnejBbuwIhAN9oBPSo71A7ZaCez3t2qgKgOCoB%2Bsxomvuk4qjccEIpKsIECDEQABoMMDM2MzQ1MzAzODE0Igz1DUabvyd%2BLb8%2BWv0qnwSatdNlTKFtSKIrkarDp76LBLd%2B%2B5%2Bl70EACsES5EVfnotaw0baqgVu5yxCnvwq5kVKG2C9ANZwCkN2bKP3gpyNcZVmobS7ZHL9kwgaiQnNC5Cwi81DXGqozkRF7epyoV%2FmcOxFRHIjNokHFICg%2FH03K3SCm%2FbTag9bJfYcDZADH%2FVshRrlwadPayLQ7V3ercU0yb1Sxdb1%2FyS8uQTiWDJ4T0tonPZaTaD7nSQnhCIalQlazfE%2Flil0kOhsPvyQ9SB9n12a2Q94Rz8ifmEX%2FBRSs%2FmS5HfDnuPAoD2dt6BTZMiOFBT%2BckwuiIjrEg4N3Negi3REETvYuwFRJEzbIiYOajqWcCbDtAGpSoPmR37yLgZsNswYcTk7vbEH3w5c0VWX12VabemesLN4mjVGs1vgIhh99Rz29LnpQsaLTu4oAFZOoh%2FiKFtubRKkz4KzBPgUS0y1sUJX4%2FsJ%2BaXU%2F2rxn7%2F0C0vNIRl5hz8YHboikl34JHTRPoNd1r%2Bujhjs0UALIduQE9zoLmQc6WEFgb0c0401%2FtTfx4qDeD3DoWNYbFsYVdU2zRFKt95FCH7nIC5Q19hrxAy4jAeN1QTMbk%2FEOE%2BUeGAgYq%2BtSY0UyTywZ1a3lqWcsdiMI3mbMOir4dJItjOCzSFZdXyO0vymNPUcbWiEYFjy4Ebar4qoteEF2Gj5y0IThhZjW0V4kxElpzi8EjG7eIKVv29GEfFnXBkwtt%2FEvwY6xAIhdy0f%2BzHDsYRdut0VVKIvv9PfDWEwQ2xwoT1eWxGkTJctznxM2MGpCIktw7JJzqmBKX%2FH81A7BDq76hNg1wCEpyGPYpMmR6lrr1SPX%2BYUhkLhHr7F5VTvbaff30IXREjhDzRygfAuVOIHbTOfJFCqt7Zr613J%2BzZABzt86my5O2dap%2Bk2R935vHfP%2Fz7yfrigOUt2x70OM6Yx9fhwJ6mQy%2FjRzWvfakKh%2FidoDZrMjHaYQYyeqbo2HmZG8X8kfeRIf0zBBHXCuDROEHlerv2UdmTs3UqY4cMNPqAp%2BdrMObkOu8A4%2B1N%2FrwIrCP0a9dKTgCexVkmumP2uq0k9trlZloZygtVErwE8aNAoqG5seYlHmnuG%2BkGGk8SlT7vCApEcZTCQkW4LPVm1VyxwoaLLfPZPNVr4Z2fPNSdeV%2BJDoEKmBho%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDGOXPH2PN%2F20250405%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250405T153357Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=f42870230e81e4b7efa0bb5304fc05ab5c01b566209e2fe60847d0b3aa7ea95c"
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