output "glue_crawler_name" {
  description = "Nome do Glue Crawler criado"
  value       = aws_glue_crawler.s3_crawler.name
}

output "athena_workgroup_name" {
  description = "Nome do Workgroup do Athena criado"
  value       = aws_athena_workgroup.athena_workgroup.name
}