#!/bin/bash
set -e

# Definir a versão desejada do Terraform
TERRAFORM_VERSION="1.11.3"

echo "📥 Baixando Terraform versão ${TERRAFORM_VERSION}..."
curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "📦 Extraindo o binário..."
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "🛠 Instalando em ~/bin..."
mkdir -p ~/bin
mv terraform ~/bin/

echo "🔧 Adicionando ~/bin ao PATH..."
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

echo "✅ Verificando instalação do Terraform..."
terraform -version

echo "🚀 Terraform instalado com sucesso!"
