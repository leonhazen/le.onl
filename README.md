## NOTE

The `ip-only` branch is what I'm actually using, much of the below has been simplified because I wanted to just publish a single lambda function at https://ip.le.onl/ as a 'What is my IP' endpoint.
The lambda_configurations below won't allow for a mapping for the root `/` path. I might still combine the two, with config for a root function and a block for additional path mappings, but it wasn't necessary for what I want.

# Personal API

The purpose of this project is to create a custom API on AWS using Terraform.

API functions are written in Python and deployed as AWS Lambda functions. AWS API Gateway is used to allow for HTTP(S) calls to invoke the Lambda functions.

CloudFlare is being used as the DNS provider. This could easily have been AWS Route53, but I already use CloudFlare for DNS and it was a good exercise to explore working across multiple providers.

## Repo Structure

```
/
- lambda/
  - func1/
    - package/ (created during packaging process)
    - main.py
    - requirements.txt
  - func2/
    - package/ (created during packaging process)
    - main.py
    - requirements.txt
- terraform/
  - main.tf
  - vars.tf
  - apigateway.tf
  - hostname.tf
  - lambda.tf
- dist/ (created during packaging process, contains zipped lambda functions)
  - func1.zip
  - func2.zip
- secrets.sh
- package_lambdas.sh
- Taskfile.yaml
```

Each API function should be placed in their own folder under `/lambda/`. Multiple actions can be in the same python file, the lambda definition specifies which handler function to be called for each API path and method, so a GET and POST method for the same entity can live in the same python script.

`lambda.tf` provides the mapping of paths and methods to functions in the local.lambda_configurations object. This dictionary is looped over in order to create each Lambda and associated API Gateway route mapping.

```
locals {
  lambda_configurations = {
    get_source_ip = {
      filename = "get_source_ip.zip"
      handler  = "main.lambda_handler"
      path     = "ip"
      method   = "GET"
    }
  }
}
```

`hostname.tf` manages all aspects of using a custom domain for the API Gateway. This includes creation of CNAME DNS records, creation of an ACM certificate, DNS validation of that certificate and mapping on the AWS API Gateway to the custom domain.

## Lambda Packaging

`package_lambdas.sh` iterates through each folder under `/lambda/` and bundles each function into a zip for Lambda to consume. As part of this process, `pip` is used to install any required python modules from `requirements.txt`.

A Taskfile is provided (https://taskfile.dev/) to provide definitions of common tasks. Currently this only includes `task build` which will execute the `package_lambdas.sh` script.

## Secrets/Credentials

Assumes you have AWS credentials configured already for AWS CLI. The AWS Terraform module will use the same environment variables already available.

CloudFlare API token is less likely to already be available in existing env vars. `secrets.sh` is a basic script to query BitWarden vault for API token and populate env var. Note that this must be dot sourced like `. ./secrets.sh` - this is required so that the env var is available after script execution.

Another key note is that sensitive values may exist in the Terraform state. Terraform recommend using Terraform cloud to provide secure state storage, or you can use S3 backed state with AWS controls such as IAM permissions and encryption at rest to provide more safety.

## API functions

GET https://api.le.onl/ip - returns requestor IP
