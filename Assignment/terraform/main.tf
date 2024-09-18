resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
   }

# Creating subnets sub1 and sub2 using terraform resource
   
    resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
     }
  
# Creating  internet gate way using terraform resource

    resource "aws_internet_gateway" "igw" {
        vpc_id = aws_vpc.main.id
    }
# Creating route table using terraform resource
  
    resource "aws_route_table" "RT" {
        vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    }
# Creating route table association using terraform resource

    resource "aws_route_table_association" "rta1" {
        subnet_id = aws_subnet.sub1.id
        route_table_id = aws_route_table.RT.id
      }
   
# Creating Security group using terraform resource

      resource "aws_security_group" "webSg" {
            vpc_id = aws_vpc.main.id
        tags = {
        Name = "web-sg"
        }
 
        ingress  {
            description = "ssh"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
                  }
  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow only from ALB
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow only from ALB
  }
        ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # API server
  }         
        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
                    }
         
      }


# Creating instance using terraform resource

      resource "aws_instance" "server1" {
        ami = "ami-0e86e20dae9224db8"
        instance_type = "t2.medium"
        vpc_security_group_ids = [aws_security_group.webSg.id]
        subnet_id = aws_subnet.sub1.id
        # Configure the root block device (OS storage)
    root_block_device {
    volume_size = 30  # Size of the root volume (in GB)
    volume_type = "gp3"  # General-purpose SSD, can be "gp2", "gp3", "io1", "io2", etc.
    delete_on_termination = true  # Ensure this volume is deleted when the instance is terminated
  }
        user_data = base64encode(file("userdata.sh"))
        tags = {
          Name = "Master"
        }
      }
         resource "aws_instance" "server2" {
        ami = "ami-0e86e20dae9224db8"
        instance_type = "t2.medium"
        vpc_security_group_ids = [aws_security_group.webSg.id]
        subnet_id = aws_subnet.sub1.id
        # Configure the root block device (OS storage)
    root_block_device {
    volume_size = 30  # Size of the root volume (in GB)
    volume_type = "gp3"  # General-purpose SSD, can be "gp2", "gp3", "io1", "io2", etc.
    delete_on_termination = true  # Ensure this volume is deleted when the instance is terminated
  }
        user_data = base64encode(file("userdata1.sh"))
         tags = {
          Name = "Node"
        }
      }
# create alb using terraform resource

      resource "aws_lb" "myalb" {
        name = "myalb"
        internal = false
        load_balancer_type = "application"
        security_groups = [aws_security_group.webSg.id]
        subnets = [aws_subnet.sub1.id]
        tags = {
          Name = "web"
        }
      }

# Creating target group using terraform
      resource "aws_lb_target_group" "tg" {
        name = "mytg"
        port = 3000
        protocol = "HTTP"
        vpc_id = aws_vpc.main.id

        health_check {
          path = "/"
          port = "3000"
        }
        }
        resource "aws_lb_target_group" "tg" {
        name = "mytg"
        port = 3001
        protocol = "HTTP"
        vpc_id = aws_vpc.main.id

        health_check {
          path = "/"
          port = "3001"
        }
        }


