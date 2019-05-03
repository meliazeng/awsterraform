resource "aws_api_gateway_rest_api" "gw" {
    name = "mvpgateway"
    endpoint_configuration {
        types = ["EDGE"]
    }
}
resource "aws_api_gateway_authorizer" "cognitoauth" {
    name                   = "gatewayauthorizer"
    type                   = "COGNITO_USER_POOLS"
    rest_api_id            = "${aws_api_gateway_rest_api.gw.id}"
    provider_arns          = ["${aws_cognito_user_pool.pool.arn}"]
}