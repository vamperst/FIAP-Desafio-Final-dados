# Executando o `script.sh` no AWS CloudShell

Siga os passos abaixo para executar o `script.sh` utilizando o AWS CloudShell:


1. **Acesse o AWS Management Console**  
    Abra o [AWS Management Console](https://aws.amazon.com/console/) e clique no ícone do **CloudShell** na barra superior.

2. **Clone o repositório**  
    No terminal do AWS CloudShell, clone o repositório contendo o script:
    ```bash
    git clone https://github.com/vamperst/FIAP-Desafio-Final-dados.git
    ```

3. **Navegue até a pasta do script**  
    Acesse o diretório onde o `script.sh` está localizado:
    ```bash
    cd Desafio-Final-dados/01-disponibilizando-os-dados
    ```

4. **Execute o script**  
    Execute o script com o comando:
    ```bash
    bash script.sh NOME_DO_BUCKET_QUE_VAI_CRIAR
    ```
