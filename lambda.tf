# Lambda Function

resource "aws_lambda_function" "html_lambda_dp" {
  filename = "index.zip"
  function_name = "myLambdaFunctionDp"
  role = aws_iam_role.lambda_role_dp.arn
  handler = "index.handler"
  runtime = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
}


# IAM Role


resource "aws_iam_role" "lambda_role_dp" {
name   = "Spacelift_Test_Lambda_Function_Role_dp"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}


resource "aws_iam_policy" "iam_policy_for_lambda_dp" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role_dp"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role_dp.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda_dp.arn
}


data "archive_file" "lambda_package" {
  type = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}


// Provision appropriate access for the Lambda function

resource "aws_iam_role_policy_attachment" "lambda_basic_dp" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role_dp.name
}

resource "aws_lambda_permission" "apigw_lambda_dp" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda_dp.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_api_dp.execution_arn}/*/*/*"
}