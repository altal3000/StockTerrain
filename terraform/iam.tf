# 1. LAMBDA ROLE
resource "aws_iam_role" "lambda_scraper_role" {
  name = "market_scraper_lambda_role_v2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_scraper_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_write" {
  name = "lambda_s3_write_policy"
  role = aws_iam_role.lambda_scraper_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.data_lake.arn}/raw/*"
    }]
  })
}

# 2. GLUE ROLE
resource "aws_iam_role" "glue_crawler_role" {
  name = "market_crawler_glue_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_read" {
  name = "glue_s3_read_policy"
  role = aws_iam_role.glue_crawler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = ["${aws_s3_bucket.data_lake.arn}", "${aws_s3_bucket.data_lake.arn}/*"]
    }]
  })
}

# 3. ATHENA/DBT ROLE
resource "aws_iam_role" "athena_dbt_role" {
  name = "market_analyst_athena_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 1. Allow Athena service to use it
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "athena.amazonaws.com" }
      },
      {
        # 2. Allow GitHub Actions to use it (OIDC)
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USER/YOUR_REPO_NAME:*"
          }
        }
      }
    ]
  })
}

# OIDC
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # GitHub's OIDC certificate
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role_policy" "athena_dbt_permissions" {
  name = "athena_dbt_policy"
  role = aws_iam_role.athena_dbt_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["athena:*", "s3:Get*", "s3:List*", "s3:PutObject"]
        Effect   = "Allow"
        Resource = ["*"] # Narrow this down later if desired
      },
      {
        Action   = ["glue:GetDatabase", "glue:GetTable", "glue:GetPartitions"]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

# 4. STEP FUNCTION & EVENTBRIDGE ORCHESTRATION

# Role for the Step Function
resource "aws_iam_role" "sfn_role" {
  name = "dbt-sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

# Unified policy for Step Function to talk to EventBridge
resource "aws_iam_role_policy" "sfn_eventbridge_policy" {
  name = "sfn-trigger-eventbridge-policy"
  role = aws_iam_role.sfn_role.id 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "events:PutEvents"
      Effect   = "Allow"
      Resource = "arn:aws:events:eu-central-1:${data.aws_caller_identity.current.account_id}:event-bus/default"
    }]
  })
}

# Role for EventBridge delivery (S3 -> SFN and SFN -> API)
resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-api-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "eventbridge-api-policy"
  role = aws_iam_role.eventbridge_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "events:InvokeApiDestination"
        Effect   = "Allow"
        Resource = aws_cloudwatch_event_api_destination.github_api.arn
      },
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret.github_token.arn
      },
      {
        Action   = "events:RetrieveConnectionCredentials"
        Effect   = "Allow"
        Resource = aws_cloudwatch_event_connection.github_conn.arn
      },
      {
        Action   = "states:StartExecution"
        Effect   = "Allow"
        Resource = aws_sfn_state_machine.dbt_trigger.arn
      }
    ]
  })
}

data "aws_caller_identity" "current" {}