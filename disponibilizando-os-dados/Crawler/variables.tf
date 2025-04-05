variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 existente"
}

variable "s3_data_path" {
  description = "Caminho dentro do bucket S3 onde os dados estão localizados"
  default     = "dados-brutos/"
}

variable "glue_database_name" {
  description = "Nome do banco de dados no Glue Catalog"
  default     = "animes_db"
}

variable "glue_crawler_name" {
  description = "Nome do Glue Crawler"
  default     = "animes_crawler"
}

variable "athena_workgroup_name" {
  description = "Nome do Workgroup do Athena"
  default     = "meu_workgroup_athena"
}

variable "athena_output_folder" {
  description = "Pasta no S3 para armazenar os resultados das consultas do Athena"
  default     = "queries_athena/"
}