# Como rodar o código de exemplo

1. Instale o Terraform Local: https://github.com/localstack/terraform-local
2. Instale o Localstack AWS CLI: https://github.com/localstack/awscli-local
3. Instale o LocalStack: https://docs.localstack.cloud/getting-started/installation/
4. Inicie o LocalStack: `localstack start`
5. Inicialize o Terraform com o comando `tflocal init`. Caso você não esteja na pasta `infra`, execute o comando `cd infra` antes.
6. Aplique a configuração do Terraform com o comando `tflocal apply`.
7. Execute o comando `awslocal sqs send-message --queue-url http://localhost:4566/000000000000/lambda-queue --message-body '{"hello": "world"}'` para enviar uma mensagem para a fila SQS.
8. Verifique os logs da função Lambda no cloudwatch utilizando os seguintes comandos:
    - `awslocal logs describe-log-groups`
    - `awslocal logs describe-log-streams --log-group-name "/aws/lambda/example_lambda"`
    - `awslocal logs get-log-events --log-group-name "/aws/lambda/example_lambda" --log-stream-name "log-stream-name"` | Obs.: Substitua **log-stream-name** pelo nome retornado no comando anterior
9. Para destruir a infraestrutura criada, execute o comando `tflocal destroy`.
10. Para parar o LocalStack, execute o comando `localstack stop`.