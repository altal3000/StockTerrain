# 1. The Catalog
resource "aws_glue_catalog_database" "stock_db" {
  name = "stockterrain_db"
}

# 2. The Crawler
resource "aws_glue_crawler" "market_data_crawler" {
  database_name = aws_glue_catalog_database.stock_db.name
  name          = "market_data_crawler"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/raw/"
  }

  # No schedule block to 'Run' in the console in case of changes
}