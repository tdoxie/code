provider "aws" {
    region = "us-east-2"
}

resource "aws_launch_configuration" "example" {
    image_id          = "ami-0c55b159cbfafe1f0"
    instance_type     = "t2.micro"
    security_groups   = [aws_security_group.instance.id]
    lifecycle {
      
      create_before_destroy = true
    }

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    
}

resource "aws_autoscaling_group" "example"{
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier  = data.aws_subnet_ids.default.ids
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"
    min_size = 2
    max_size =10

    tag{
     key                 = "Name"
     value               = "terraform-asg-example"
     propagate_at_launch = true
    
    }
}


resource "aws_security_group" "instance"{
  name = "terraform-example-instance"
   ingress {
       from_port = var.server_port
       to_port   = var.server_port
       protocol = "tcp"
       cidr_blocks =  ["0.0.0.0/0"]
   }
}

#output "Public_IP" {
#  value = aws_instance.example.public_ip
#}