import os
import boto3
import requests
import zipfile
import io

def lambda_handler(event, context):
    s3_bucket = os.environ["S3_BUCKET"]
    s3_output_prefix = os.environ.get("S3_OUTPUT_PREFIX", "unzipped/")
    signed_url = os.environ["SIGNED_ZIP_URL"]

    # Fazer o download do ZIP
    print(f"Baixando o ZIP de: {signed_url}")
    response = requests.get(signed_url)
    response.raise_for_status()

    # Abrir o conteúdo ZIP em memória
    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        s3 = boto3.client("s3")
        for file_name in z.namelist():
            if file_name.endswith("/"):  # Pula diretórios
                continue
            file_data = z.read(file_name)
            s3_key = f"{s3_output_prefix}{file_name}"
            print(f"Enviando {file_name} para s3://{s3_bucket}/{s3_key}")
            s3.put_object(Bucket=s3_bucket, Key=s3_key, Body=file_data)

    return {"statusCode": 200, "body": "Arquivos extraídos e enviados com sucesso."}