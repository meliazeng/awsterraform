resource "aws_security_group" "allowrdp" {
    name        = "allow_rdp"
    description = "Allow rdp inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"
    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "allow_rdp"
    }
}
resource "aws_security_group" "neo4jinternal" {
    name        = "allow_neo4j"
    description = "Allow neo4j internal inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"
    ingress {
        from_port   = 7687
        to_port     = 7687
        protocol    = "tcp"
        cidr_blocks = ["172.21.0.0/16"]
    }
    ingress {
        from_port   = 7474
        to_port     = 7474
        protocol    = "tcp"
        cidr_blocks = ["172.21.0.0/16"]
    }
    ingress {
        from_port   = 7473
        to_port     = 7473
        protocol    = "tcp"
        cidr_blocks = ["172.21.0.0/16"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${aws_instance.jumpbox.private_ip}/32"]
    }
    tags {
        Name = "for_neo4j"
    }
}