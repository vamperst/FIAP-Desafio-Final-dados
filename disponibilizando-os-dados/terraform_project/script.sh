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
LINK_TO_DATASET="https://rb.gy/vuzxp4"

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

# Verificando se o dataset já foi baixado
if [ -d "dataset" ]; then
    echo "O dataset já foi baixado."
else
    echo "O dataset não foi encontrado. Iniciando o download..."
    # Fazendo o download do dataset
    wget $LINK_TO_DATASET -O dataset.zip
    # Verificando se o download foi bem-sucedido
    if [ $? -eq 0 ]; then
        echo "Download do dataset concluído com sucesso."
    else
        echo "Erro ao fazer o download do dataset."
        exit 1
    fi
    # Descompactando o arquivo
    unzip dataset.zip -d dataset
    # Verificando se a descompactação foi bem-sucedida
    if [ $? -eq 0 ]; then
        echo "Descompactação do dataset concluída com sucesso."
    else
        echo "Erro ao descompactar o dataset."
        exit 1
    fi
    # Fazendo o upload do dataset para o bucket S3
    aws configure set default.s3.max_concurrent_requests 5 
    aws configure set default.s3.multipart_threshold 64MB  
    aws configure set default.s3.multipart_chunksize 16MB
    aws s3 cp dataset/parquet-files/ s3://$BUCKET_NAME/$DATASET_PATH_S3 --recursive
    # Verificando se o upload foi bem-sucedido
    if [ $? -eq 0 ]; then
        echo "Upload do dataset para o bucket $BUCKET_NAME concluído com sucesso."
    else
        echo "Erro ao fazer o upload do dataset para o bucket $BUCKET_NAME."
        exit 1
    fi
fi

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
aws glue start-crawler --name meu-crawler
# Verificando se o crawler foi iniciado com sucesso
if [ $? -eq 0 ]; then
    echo "Crawler iniciado com sucesso."
else
    echo "Erro ao iniciar o crawler."
    exit 1
fi
# Verificando o status do crawler
while true; do
    STATUS=$(aws glue get-crawler --name meu-crawler --query 'Crawler.State' --output text)
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
# Script finalizado
echo "Script finalizado com sucesso."