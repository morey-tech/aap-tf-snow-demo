
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true

  tags = {
    Name = "AWS VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id  
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = aws_vpc.main.cidr_block
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gateway.id
 }
}

resource "aws_route_table_association" "route_table_association" {
 subnet_id      = aws_subnet.main.id
 route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "allow_traffic" {
  name = "allow_traffic"
  description = "Allow traffic"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

# Create the load balancer
resource "aws_instance" "loadbalancer" {
  count = 1
  instance_type = "t2.micro"
  ami = var.ami
  key_name = var.key_instance_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  tags ={
      Name = var.instance_name_lb,
      Owner = "nmorey",
      type =  "${var.application_name}_lb",
      project =  var.application_name
      provider: "aws"
    }
}

# Create the Web Servers
resource "aws_instance" "webserver" {
  count = var.webserver_count
  instance_type = "t2.medium"
  ami = var.ami
  key_name = var.key_instance_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  tags ={
      Name = "${var.instance_name_webserver}_${count.index}",
      Owner = "nmorey",
      type =  "${var.application_name}_web",
      project =  var.application_name
      provider: "aws"
    }
}