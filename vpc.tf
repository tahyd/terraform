resource "aws_vpc" "main_test_vpc"{
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "main_test_vpc"
    }

}


/* Craete Sub nets */
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_test_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_test_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}


/*Create Internet Gateway*/

resource "aws_internet_gateway" "test_igw1" {
  vpc_id = aws_vpc.main_test_vpc.id

  tags = {
    Name = "test_igw1"
  }
}

/* Create Route Table*/
resource "aws_route_table" "public_route" {

     vpc_id = aws_vpc.main_test_vpc.id
      

      tags ={
        Name = "public_route_table_Test_VPC"
      }

      route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.test_igw1.id 
      }
}


resource "aws_route_table" "private_route" {

     vpc_id = aws_vpc.main_test_vpc.id

      tags ={
        Name = "private_route_table_Test_VPC"
      }

      route {
         cidr_block = "0.0.0.0/0"
         nat_gateway_id = aws_nat_gateway.test_nat.id 
      }

      
}


/* Route table association*/


resource "aws_route_table_association" "rt_association_public"{
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "rt_association_private"{
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route.id
}





/*create elastic IP*/

resource "aws_eip" "lb" {
  
  domain   = "vpc"
}

/* Create Nat gateway*/


resource "aws_nat_gateway" "test_nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.test_igw1]
}

output "eip_public_id" {
  value       = aws_eip.lb.public_ip
  
}