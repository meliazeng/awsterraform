
resource "aws_vpc" "main" {
    cidr_block          = "172.21.0.0/16"
    enable_dns_support    = true
    enable_dns_hostnames  = true
    tags {
        name = "${var.enviroument_name}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        name = "${var.enviroument_name}"
    }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "PublicSubnet1" {
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "172.21.10.0/24"
    availability_zone   = "${data.aws_availability_zones.available.names[0]}"
    map_public_ip_on_launch = true
    tags {
        name = "${var.enviroument_name} Public Subnet (AZ1)"
    }        
}

resource "aws_subnet" "PublicSubnet2" {
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "172.21.30.0/24"
    availability_zone   =  "${data.aws_availability_zones.available.names[1]}"
    map_public_ip_on_launch = true
    tags {
        name = "${var.enviroument_name} Public Subnet (AZ2)"
    }        
}

resource "aws_subnet" "PrivateSubnet1" {
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "172.21.20.0/24"
    availability_zone   = "${data.aws_availability_zones.available.names[0]}"
    map_public_ip_on_launch = false
    tags {
        name = "${var.enviroument_name} Private Subnet (AZ1)"
    }        
}

resource "aws_subnet" "PrivateSubnet2" {
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "172.21.40.0/24"
    availability_zone   = "${data.aws_availability_zones.available.names[1]}"
    map_public_ip_on_launch = false
    tags {
        name = "${var.enviroument_name} Private Subnet (AZ2)"
    } 
}

resource "aws_eip" "NatGateway1EIP" {
    vpc         = true
    #instance    = "${aws_instance.jumpbox.id}"
    depends_on  = ["aws_internet_gateway.gw"] 
}

resource "aws_eip" "NatGateway2EIP" {
    vpc         = true
    depends_on  = ["aws_internet_gateway.gw"] 
}

resource "aws_nat_gateway" "NatGateway1" {
    allocation_id   = "${aws_eip.NatGateway1EIP.id}"
    subnet_id       = "${aws_subnet.PublicSubnet1.id}"
}

resource "aws_nat_gateway" "NatGateway2" {
    allocation_id   = "${aws_eip.NatGateway2EIP.id}"
    subnet_id       = "${aws_subnet.PublicSubnet2.id}"
}

resource "aws_route_table" "PublicRouteTable" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        name = "${var.enviroument_name}  Public Routes"
    }  
    route {
        cidr_block    = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}
resource "aws_route_table_association" "PublicSubnet1RouteTableAssociation" {
    subnet_id      = "${aws_subnet.PublicSubnet1.id}"
    route_table_id = "${aws_route_table.PublicRouteTable.id}"
}
resource "aws_route_table_association" "PublicSubnet2RouteTableAssociation" {
    subnet_id      = "${aws_subnet.PublicSubnet2.id}"
    route_table_id = "${aws_route_table.PublicRouteTable.id}"
}
resource "aws_route_table" "PrivateRouteTable1" {
    vpc_id = "${aws_vpc.main.id}"
        tags {
            name = "${var.enviroument_name}  Private Routes (AZ1)"
        }  

    route {
        cidr_block              = "0.0.0.0/0"
        nat_gateway_id          = "${aws_nat_gateway.NatGateway1.id}"
    }
}
resource "aws_route_table_association" "PrivateSubnet1RouteTableAssociation" {
    subnet_id      = "${aws_subnet.PrivateSubnet1.id}"
    route_table_id = "${aws_route_table.PrivateRouteTable1.id}"
}
resource "aws_route_table" "PrivateRouteTable2" {
    vpc_id = "${aws_vpc.main.id}"
        tags {
            name = "${var.enviroument_name}  Private Routes (AZ2)"
        }  

    route {
        cidr_block              = "0.0.0.0/0"
        nat_gateway_id          = "${aws_nat_gateway.NatGateway2.id}"
    }
}
resource "aws_route_table_association" "PrivateSubnet2RouteTableAssociation" {
    subnet_id      = "${aws_subnet.PrivateSubnet2.id}"
    route_table_id = "${aws_route_table.PrivateRouteTable2.id}"
}

resource "aws_security_group" "NoIngressSecurityGroup" {
    name        = "no-ingress-sg"
    description = "Security group with no ingress rule"
    vpc_id      = "${aws_vpc.main.id}"
}

output "vpc" {
    value       = "${aws_vpc.main.id}"
    description = "A reference to the created VPC"
}
output "PublicSubnet1" {
    value       = "${aws_subnet.PublicSubnet1.id}"
    description = "A reference to the public subnet in the 1st Availability Zone"
}
output "PublicSubnet2" {
    value       = "${aws_subnet.PublicSubnet2.id}"
    description = "A reference to the public subnet in the 2nd Availability Zone"
}
output "PrivateSubnet1" {
    value       = "${aws_subnet.PrivateSubnet1.id}"
    description = "A reference to the private subnet in the 1st Availability Zone"
}
output "PrivateSubnet2" {
    value       = "${aws_subnet.PrivateSubnet2.id}"
    description = "A reference to the private subnet in the 2nd Availability Zone"
}
output "NoIngressSecurityGroup" {
    value       = "${aws_security_group.NoIngressSecurityGroup.id}"
    description = "Security group with no ingress rule"
}
