
/*resource "aws_key_pair" "deployer" {
    key_name   = "NEO4J-DEV-KEY"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}*/
resource "tls_private_key" "keyprivate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "keypublic" {
  key_name   = "NEO4J-DEV-KEY"
  public_key = "${tls_private_key.keyprivate.public_key_openssh}"
}
resource "aws_instance" "jumpbox" {
    ami                     = "ami-0204606704df03e7e"
    instance_type           = "t2.micro"
    subnet_id               = "${aws_subnet.PublicSubnet1.id}"
    key_name                = "NEO4J-DEV-KEY"
    get_password_data       = false
    associate_public_ip_address =  true
    vpc_security_group_ids  = ["${aws_security_group.allowrdp.id}"]
    tags = {
        Name = "JumpBox"
    }
}
module "neo4j" {
    source              = "./neo4j"
    project             = "${var.project}"
    core_type           = "t2.medium"
    environment         = "${var.enviroument_name}"
    name                = "neo4j"
    key_name            = "NEO4J-DEV-KEY"
    volume_size         = 50
    ami                 = "ami-0118d82e9da26d491"
    vpc_id              = "${aws_vpc.main.id}"
    subnet_ids          = ["${aws_subnet.PrivateSubnet1.id}"]
    security_group_ids  = ["${aws_security_group.neo4jinternal.id}"]
    backup_enabled      = true
    core_count          = 1
    tags = {
        Name = "NEO4j Box"
    }
}

output "neo4j_Private_ip" {
    value = "${module.neo4j.instance_private_ips}"
    description = "Ip address of Neo4j instance."
} 
output "jumpbox_private_ip" {
    value = "${aws_instance.jumpbox.private_ip}"
    description = "Private ip address of Neo4j instance."
}
output "jumpbox_public_ip" {
    value = "${aws_instance.jumpbox.public_ip}"
    description = "Public ip address of Neo4j instance."
}

output "jumpbox_password" {
    value = "${tls_private_key.keyprivate.private_key_pem}"
    description = "The private key to access instance."
}
