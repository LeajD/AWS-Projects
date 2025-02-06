resource "aws_instance" "docker_build_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your region's Ubuntu AMI
  instance_type = "t3.micro"
  key_name      = "your-key-name"
  
  tags = {
    Name = "Docker Build EC2"
  }

  # Allow SSH from anywhere (for convenience in this example)
  security_groups = [aws_security_group.docker_build_sg.name]

  # Userdata to install Docker and other tools
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io git maven
              EOF
}

resource "aws_security_group" "docker_build_sg" {
  name_prefix = "docker_build_sg"
  
  ingress {
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
}


resource "aws_instance" "java_build_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your region's Ubuntu AMI
  instance_type = "t3.micro"
  key_name      = "your-key-name"
  
  tags = {
    Name = "Java Build EC2"
  }

  # Allow SSH from anywhere (for convenience in this example)
  security_groups = [aws_security_group.java_build_sg.name]

  # Userdata to install Java and Maven
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y openjdk-11-jdk maven git
              EOF
}

resource "aws_security_group" "java_build_sg" {
  name_prefix = "java_build_sg"
  
  ingress {
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
}



