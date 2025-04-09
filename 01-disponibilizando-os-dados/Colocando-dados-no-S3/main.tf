provider "aws" {
  region = "us-east-1"
}

locals {
  short_id = substr(md5(uuid()), 0, 6)
}

variable "s3_bucket_name" {
  description = "Bucket de destino para arquivos descompactados"
  type        = string
}

variable "signed_zip_url" {
  description = "URL assinada do arquivo .zip no S3"
  type        = string
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-unzip-s3-role-${local.short_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda-unzip-s3-policy-${local.short_id}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject"
      ],
      Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
    }]
  })
}

resource "aws_lambda_function" "unzip_lambda" {
  function_name = "S3ZipUnpacker-${local.short_id}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 2048

  filename         = "lambda_unzip_s3.zip"
  source_code_hash = filebase64sha256("lambda_unzip_s3.zip")

  environment {
    variables = {
      S3_BUCKET       = var.s3_bucket_name
      SIGNED_ZIP_URL  = var.signed_zip_url
      S3_OUTPUT_PREFIX = "dados-brutos/"
    }
  }
}

resource "aws_lambda_invocation" "run_lambda" {
  function_name = aws_lambda_function.unzip_lambda.function_name
  input         = jsonencode({})
  depends_on    = [aws_lambda_function.unzip_lambda]
}
