# 1. Fetch GitHub Token
data "aws_secretsmanager_secret" "github_token" {
  name = "github_pat"
}

data "aws_secretsmanager_secret_version" "github_token_val" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

# 2. Connection & Destination
resource "aws_cloudwatch_event_connection" "github_conn" {
  name               = "github-connection"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${data.aws_secretsmanager_secret_version.github_token_val.secret_string}"
    }
    
    invocation_http_parameters {
      header {
        key   = "Accept"
        value = "application/vnd.github+json"
      }
      header {
        key   = "X-GitHub-Api-Version"
        value = "2022-11-28"
      }
      header {
        key   = "User-Agent"
        value = "AWS-EventBridge"
      }
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "github_api" {
  name                = "github-dbt-trigger"
  # Try using the repository dispatch or double-check the workflow dispatch URL
  invocation_endpoint = "https://api.github.com/repos/altal3000/StockTerrain/actions/workflows/dbt_run.yml/dispatches"
  http_method         = "POST"
  connection_arn      = aws_cloudwatch_event_connection.github_conn.arn
}

# 3. Step Function
resource "aws_sfn_state_machine" "dbt_trigger" {
  name     = "dbt-trigger-github"
  role_arn = aws_iam_role.sfn_role.arn
  definition = jsonencode({
    StartAt = "RunGitHubAction"
    States = {
      RunGitHubAction = {
        Type     = "Task"
        Resource = "arn:aws:states:::events:putEvents"
        Parameters = {
          Entries = [
            {
              Source       = "my.dbt.orchestrator"
              DetailType   = "Trigger GitHub Action"
              Detail       = jsonencode({ ref = "main" })
              EventBusName = "default"
            }
          ]
        }
        End = true
      }
    }
  })
}

# 4. Trigger Rule
resource "aws_cloudwatch_event_rule" "trigger_github_rule" {
  name          = "trigger-github-api-rule"
  event_pattern = jsonencode({
    source = ["my.dbt.orchestrator"]
  })
}

resource "aws_cloudwatch_event_target" "github_target" {
  rule      = aws_cloudwatch_event_rule.trigger_github_rule.name
  arn       = aws_cloudwatch_event_api_destination.github_api.arn
  role_arn  = aws_iam_role.eventbridge_role.arn

  input_transformer {
    input_paths = {
      ref = "$.detail.ref"
    }
    input_template = <<EOF
{
  "ref": "<ref>",
  "inputs": {}
}
EOF
  }
}

# 5. Match new object events in the raw/ folder
resource "aws_cloudwatch_event_rule" "s3_upload_rule" {
  name        = "trigger-sfn-on-s3-upload"
  description = "Trigger Step Function when a file is uploaded to S3 raw folder"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = { name = [aws_s3_bucket.data_lake.id] }
      object = { key = [{ prefix = "raw/" }] }
    }
  })
}

# 6. Send the S3 event to Step Function
resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.s3_upload_rule.name
  arn       = aws_sfn_state_machine.dbt_trigger.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}