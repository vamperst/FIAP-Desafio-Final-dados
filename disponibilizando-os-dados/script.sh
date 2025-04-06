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
LINK_TO_DATASET="https://teste-dia-12.s3.us-east-1.amazonaws.com/dataset.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEM3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIFIHc8igbDxOybpy2YuIkaz%2FJ%2BrhR3A%2BEgS29jnZbsG5AiAQfrEKB1BHT2IDPeUFqQQYjskKU1WlkSMtoRSDekhUtCrCBAhGEAAaDDAzNjM0NTMwMzgxNCIMjV1q4BGA2raunOp8Kp8EAhBJ7twd%2FcI%2BW56pCS5dOtF6wj3f9iJSiAWGGqZGxU8kJozmnIuW6qQ9f8fho7H0pHseBsBNoZr76gFly2Yj7gNMwO9UWoUKhmoVgxhFtKaW1YJg%2BwfPHFuPbX49Urp0iwQfwW3R0dwBrOUgW94Rk9heux%2FGPAiKrmxvnqrL1QcAbtFfZALMyktjSjuekf39nZTZvLdr5cLFaVyH4vhAN5G9EyKNQdbHjMAC0Bd%2BluIHvKOzNYYN7gnow8pOhK3vbZt0GvaYr8RDFMRMZWugYl6qhsSlPi9rDc45Ncym8xkmaMQsyVlMtW%2FMmOXQmXEz8BHKyvY3ghlOmpko9gS4FhpesZz3ZcXPnDUBiZRZYgA%2BYhuVJSg05%2FpJDbhqL6eujwwXkwI91CMq94GsJByqPAZKCwyEIKdZvkd0WmdFwjsBT7viOmOrwUg2guOOtIcm0319VWPSsA6VR%2BW%2F%2BL0w2y5pLhWJGRNKPWMmB%2F%2FHWflXMrbAanxML65J%2FGh%2Bo5Av3BtQljng%2Bm5ZohhXjy9YQqOlIkmYF6p%2FHt7F3FjPmX%2FUpnvJc6iJdoz3zxUU75rVB97YCcdN%2Be4Oxaty6W9hi%2BALErAUoYGJ%2FEvZ3Qo%2BnR%2FfuxaIwCrU9qweft7eq%2FqpJUCyeENIx%2B6dbii9wGVqFRMidV%2FR8DwrQs4EkBzzEQom%2BQm11eSp0fnJj1H1yHjuI8HFmLE614NcaP0sJ%2BqxMJ3myb8GOsYC6LCu4RPiVDFIBcSVlVzsq0%2FHG68XGuC7MkM%2F%2FRfBfMLt2XPKz5FHmKYZDWBxVjz3Ge1HkkKELJZN4CBmiAk6wf%2FZ%2FkU2myfqPUglUjinxXMh1wLGbqJHMSMj%2BzL3G7t5CGfJoVzm2wL7aGQBUoU%2BJ2Vam079ToXYPRXgGCcXXHpbmaNlkpe3Sy0ijFi5%2FJ75SGrsFbnGr87OFQH1CS0KduNuMDoBlkCbNIXJA8Gqpr5%2BDorRNz9dm%2F3Q%2BZqhoq4%2Bl0OEv1PBsr56rWaOYNzY9r00xqsny74UPc2Kkht1U1uCWwPjQ3LH7tFr2LznZCZqsEYf6uXDLSLWrKlwjKECn6ZF42ZVvzc9m8OlS4iXiCU4Uxsh%2F9zPMOUxfMG8G1YbTYRVujM7a%2BJ5qeVz%2Ba0kwGn1dM0Ur3peOZRsWIjT8txJpClhXys%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQQ5SZKMDCLA2VQSJ%2F20250406%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250406T122814Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=d005891950c044eb465e3fb8e07ee314f894daf273f64a08fe0ac15c2a9d1de5"
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