import os
import boto3
import urllib.request
import zipfile
import io

def lambda_handler(event, context):
    s3_bucket = os.environ["S3_BUCKET"]
    s3_output_prefix = os.environ.get("S3_OUTPUT_PREFIX", "dados-brutos/")
    signed_url = os.environ["SIGNED_ZIP_URL"]

    # Baixar o arquivo ZIP usando urllib (sem requests!)
    print(f"Baixando o ZIP de: {signed_url}")
    with urllib.request.urlopen(signed_url) as response:
        zip_content = response.read()

    # Descompactar em memória
    with zipfile.ZipFile(io.BytesIO(zip_content)) as z:
        s3 = boto3.client("s3")
        for file_name in z.namelist():
            if file_name.endswith("/"):
                continue  # ignora diretórios
            file_data = z.read(file_name)
            s3_key = f"{s3_output_prefix}{file_name}"
            print(f"Enviando {file_name} para s3://{s3_bucket}/{s3_key}")
            s3.put_object(Bucket=s3_bucket, Key=s3_key, Body=file_data)

    return {
        "statusCode": 200,
        "body": f"Arquivos descompactados e enviados para {s3_bucket}/{s3_output_prefix}"
    }
