# 1. Create a folder for query results in S3
resource "aws_s3_object" "athena_results_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "athena_results/"
}

# 2. Setup the Workgroup
resource "aws_athena_workgroup" "primary" {
  name = "market_data_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_lake.bucket}/athena_results/"
    }
  }
}