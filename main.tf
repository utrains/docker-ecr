# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
}

  # Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "docker-Web-SG"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
      description = "ingress port "
      #from_port   = ingress.value
      from_port   = 8000
      to_port     = 8100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress {
      description = "ingress port "
      #from_port   = ingress.value
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress {
      description = "ingress-port "
      #from_port   = ingress.value
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-Web-SG"
  }
}

  
# Generates a secure private k ey and encodes it as PEM
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "docker-keypair"  
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ec2_key.key_name}.pem"
  content  = tls_private_key.ec2_key.private_key_pem
  file_permission = "400"
}

#data for amazon linux

data "aws_ami" "amazon-2" {
    most_recent = true
  
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
    owners = ["amazon"]
  }
 
#create ec2 instances 

resource "aws_instance" "DockerInstance" {
  ami                    = data.aws_ami.amazon-2.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.ec2_key.key_name
  #user_data              = file("install.sh")
  iam_instance_profile   = aws_iam_instance_profile.docker_ecr_profile.name
  root_block_device {
    volume_size = 30  
    volume_type = "gp2"  
  }

  tags = {
    Name = "docker-instance"
  }
  provisioner "file" {
    source      = "${path.module}/installation/"
    destination = "/home/ec2-user/"

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(local_file.ssh_key.filename)
      host        = self.public_ip
      timeout     = "1m"
    }
  }
 depends_on = [ aws_ecr_repository.ecr1 ]
 
}
resource "null_resource" "n1" {
  // connect to docker server , build and push image to ecr
  connection {
    host = aws_instance.DockerInstance.public_ip
    type = "ssh"
    port = 22
    user = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
  }

  provisioner "remote-exec" {
    inline = [ 
      "ls",
      "sudo yum install dos2unix -y",
      "dos2unix /home/ec2-user/install.sh",
      "sh /home/ec2-user/install.sh ${var.region}  ${aws_ecr_repository.ecr1.repository_url}" ,
     ]
  }
 depends_on = [ aws_instance.DockerInstance ] 
}