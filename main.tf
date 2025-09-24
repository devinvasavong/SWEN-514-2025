# --- Data sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
    aws_key = "514_Key"   # SSH key pair name for EC2 instance access
}

# --- Security group ---
resource "aws_security_group" "wp" {
  name        = "tf-wp-sg"
  description = "allow ssh/http/https"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # tighten to your /32 if you want
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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

# --- Instance ---
resource "aws_instance" "my_server" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = var.instance_type
  key_name                    = local.aws_key

  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.wp.id]
  associate_public_ip_address = true

  user_data                   = file("${path.module}/wp_install.sh")
  user_data_replace_on_change = true

  tags = { Name = "my ec2" }
}