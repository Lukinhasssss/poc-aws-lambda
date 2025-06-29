provider "aws" {
  access_key = "localstack"
  secret_key = "localstack"
  region     = "sa-east-1"
}

### Inicio da configuração do bucket S3 para armazenar o código da função Lambda
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-bucket"
  tags = {
    name        = "lambda-bucket"
    description = "Bucket para armazenar o código da função Lambda"
    environment = "test"
  }
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function.zip"
  source = "../app/lambda_function.zip"
}
### Fim da configuração do bucket S3



### Início da configuração do SQS Queue | Permite que a função Lambda seja acionada por mensagens na fila
resource "aws_sqs_queue" "lambda_queue" {
  name = "lambda-queue"
}
### Fim da configuração do SQS Queue



### Início da configuração do IAM Role para a função Lambda | Permite que a função Lambda seja executada
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "lambda.amazonaws.com" }
        }
      ]
    }
  )
}

# No Terraform, você não precisa criar manualmente o grupo de logs do CloudWatch para AWS Lambda: a própria Lambda cria o grupo
# /aws/lambda/<nome_da_lambda> automaticamente na primeira execução, desde que a role da Lambda tenha as permissões de logs
resource "aws_iam_role_policy" "lambda_logs" {
  name = "lambda_logs"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    }
  )
}
### Fim da configuração do IAM Role



### Início da configuração da Lambda Function | Define a função Lambda que será acionada pelo SQS
resource "aws_lambda_function" "example" {
  function_name = "example_lambda"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_zip.id
  handler       = "handler.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  depends_on    = [aws_s3_object.lambda_zip]
}

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.lambda_queue.arn
  function_name    = aws_lambda_function.example.arn
  batch_size       = 1
  enabled          = true
}
### Fim da configuração da Lambda Function



### Inicio da configuração do grupo de logs do CloudWatch | Permite que a função Lambda registre logs
resource "aws_cloudwatch_log_group" "lambda_cloudwatch_logs" {
  name = "/aws/lambda/example_lambda"
  retention_in_days = 7
}
### Fim da configuração do grupo de logs do CloudWatch