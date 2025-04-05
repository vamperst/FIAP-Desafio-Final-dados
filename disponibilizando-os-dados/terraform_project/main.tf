provider "aws" {
  region = var.aws_region
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_object" "athena_results_folder" {
  bucket = data.aws_s3_bucket.existing_bucket.bucket
  key    = var.athena_output_folder
}

resource "aws_iam_role" "glue_role" {
  name = "fiap-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_service" {
  name       = "fiap-glue-service-policy"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "s3_access" {
  name = "GlueS3AccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          data.aws_s3_bucket.existing_bucket.arn,
          "${data.aws_s3_bucket.existing_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_glue_catalog_database" "glue_database" {
  name = var.glue_database_name
}

resource "aws_glue_crawler" "s3_crawler" {
  name          = var.glue_crawler_name
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.glue_database.name

  s3_target {
    path = "s3://${data.aws_s3_bucket.existing_bucket.bucket}/${var.s3_data_path}/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = var.athena_workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${data.aws_s3_bucket.existing_bucket.bucket}/${var.athena_output_folder}"
    }
  }
}