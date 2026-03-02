resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "data_lake" {
  bucket = "stockterrain-datalake-${random_id.suffix.hex}"
}