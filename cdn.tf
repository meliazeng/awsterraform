locals{
    s3_static_origin_id="MVPStaticOrigin"
    s3_user_origin_id="MVPUserOrigin"
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

resource "aws_cloudfront_distribution" "mvpcdn" {
    origin {
        domain_name = "${aws_s3_bucket.mvpstatic.bucket_domain_name}"
        origin_id   = "${local.s3_static_origin_id}"
        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
        }
    }
    origin {
        domain_name = "${aws_s3_bucket.mvpuser.bucket_domain_name}"
        origin_id   = "${local.s3_user_origin_id}"
        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
        }
    }
    enabled             = true
    is_ipv6_enabled     = false
    comment             = "Static COntent"
    default_root_object = "index.html"
    #aliases = ["${var.enviroument_name}.${var.cdn_root_domain_name}"]
    tags {
        Environment = "${var.enviroument_name}"
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${local.s3_static_origin_id}"
        forwarded_values {
            query_string = false
            headers = ["${var.cdn_header}"]
            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
        compress               = true
        viewer_protocol_policy = "redirect-to-https"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}
output "cdn_url" {
    value = "${aws_cloudfront_distribution.mvpcdn.domain_name}"
    description = "cloudfront url"
}