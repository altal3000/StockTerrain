# 1. Package scraper.py into a zip automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/scraper.py" # Adjusted path
  output_path = "${path.module}/scraper_code.zip"
}

# 2. Define the yfinance layer
resource "aws_lambda_layer_version" "yfinance" {
  filename            = "${path.module}/../src/yfinance_layer.zip" # Adjusted path
  layer_name          = "yfinance_lib"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = filebase64sha256("${path.module}/../src/yfinance_layer.zip")
}

# 3. Create the Lambda Function
resource "aws_lambda_function" "market_scraper" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "daily_market_scraper"
  role             = aws_iam_role.lambda_scraper_role.arn
  handler          = "scraper.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [
    "arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python312:12",
    aws_lambda_layer_version.yfinance.arn
  ]
}

# 4. Create the schedule
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "market_data_daily_sync"
  schedule_expression = "cron(0 8 * * ? *)"
}

# 5. Link the schedule to the Lambda
resource "aws_cloudwatch_event_target" "trigger_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "daily_market_scraper"
  arn       = aws_lambda_function.market_scraper.arn
}

# 6. Give EventBridge permission to run Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.market_scraper.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}