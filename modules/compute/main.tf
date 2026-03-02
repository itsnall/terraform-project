resource "aws_launch_template" "fgd3_template" {
  name_prefix   = "fgd3-template-"
  image_id      = var.os_name
  instance_type = var.instance_type
  key_name      = var.key


  vpc_security_group_ids = [aws_security_group.fgd3-vpc-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    db_endpoint = var.db_endpoint
    index_php_content = file("${path.module}/index.php")
  }))
}

// Security Group EC2 (App Layer)
resource "aws_security_group" "fgd3-vpc-sg" {
  name        = "fgd3-vpc-sg"
  vpc_id      = var.vpc_id


  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.10.0.0/16"] 
  }

  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    cidr_blocks     = ["10.10.0.0/16"]
  }

  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "fgd3-vpc-sg"
  }
}


# --- Security Group untuk ALB ---
resource "aws_security_group" "alb_sg" {
  name        = "fgd3-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

# --- Application Load Balancer ---
resource "aws_lb" "fgd3_alb" {
  name               = "fgd3-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids 

  tags = { Name = "fgd3-alb" }
}

# --- Target Group ---
resource "aws_lb_target_group" "fgd3_tg" {
  name     = "fgd3-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

# --- Listener ---
resource "aws_lb_listener" "fgd3_listener" {
  load_balancer_arn = aws_lb.fgd3_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fgd3_tg.arn
  }
}

resource "aws_autoscaling_group" "fgd3_asg" {
  name                = "fgd3-asg"
  
  
  vpc_zone_identifier = [var.app_subnet_id] 
  
  
  target_group_arns   = [aws_lb_target_group.fgd3_tg.arn]

  
  desired_capacity    = 2  
  min_size            = 1  
  max_size            = 3  

  launch_template {
    id      = aws_launch_template.fgd3_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "fgd3-asg-server"
    propagate_at_launch = true
  }
}


//AWS SSM 

# --- CARD ACCESS (IAM Role) FOR EC2 ---
resource "aws_iam_role" "ssm_role" {
  name = "fgd3-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# --- PERMISSION TO SSM ---
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- PACKAGE Role INTO Instance Profile FOR EC 2 ---
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "fgd3-ssm-profile"
  role = aws_iam_role.ssm_role.name
}