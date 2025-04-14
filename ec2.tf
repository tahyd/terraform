resource "aws_instance" "webserver" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

     subnet_id  = aws_subnet.public_subnet.id
  
  associate_public_ip_address = true
    tags = {
        Name = "Webserver"
        Description = "an nginx machine"
    }

    user_data = <<-EOF
         #!/bin/bash
         sudo apt update
         sudo apt install nginx -y
         systemctl enable nginx
         systemctl start nginx
    EOF 

    key_name = aws_key_pair.web_key.id
vpc_security_group_ids = [aws_security_group.ssh-access.id]
}


resource "aws_key_pair" "web_key" {

    public_key = file("C:/Users/HSBC/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "ssh-access" {
    vpc_id  = aws_vpc.main_test_vpc.id
    name = "ssh-access"
    description = "allow ssh connection from internet"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.ssh-access.id
 cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ssh-access.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}