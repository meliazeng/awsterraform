resource "aws_s3_bucket" "mvpstatic" {
    acl = "public-read"
    website {
        index_document="index.html"
        error_document = "index.html"
    }
    tags = {
        Name = "mvpstatic"
        env ="${var.enviroument_name}"
    }
}
resource "aws_s3_bucket_policy" "mvpstaticpolicy" {
    bucket = "${aws_s3_bucket.mvpstatic.id}" 
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "${aws_s3_bucket.mvpstatic.arn}",
                "${aws_s3_bucket.mvpstatic.arn}/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "${var.cdn_header}"
                }
            }
        }
    ]
}
POLICY
}
resource "aws_s3_bucket" "mvpuser" {
    acl = "private"
    tags = {
        Name = "mvpuser"
        env ="${var.enviroument_name}"
    }
}
resource "aws_s3_bucket_policy" "mvpuserpolicy" {
    bucket = "${aws_s3_bucket.mvpuser.id}" 
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.mvpuser.arn}/users/public/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "${var.cdn_header}"
                }
            }
        }
    ]
} 
POLICY
}
output "s3_static_arn" {
    value = "${aws_s3_bucket.mvpstatic.arn}"
    description = "Arn of s3 static website."
}
output "s3_user_arn" {
    value = "${aws_s3_bucket.mvpuser.arn}"
    description = "Arn of s3 mvpuser."
}
