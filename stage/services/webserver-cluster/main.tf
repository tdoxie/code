#terraform {
#  required_version = ">= 0.12, < 0.13"
#}

provider "aws" {
  region = "us-east-2"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = var.cluster_name
  db_remote_state_bucket = "terraform-state-ttd"
  db_remote_state_key    = "stage/data-store/mysql/terraform.tfstate"
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
#terraform {
 # backend "s3" {
  #  bucket = "terraform-state-ttd"
   # key = "stage/services/webserver-cluster/terraform.tfstate"
    #region = "us-east-2"
   # dynamodb_table = "terraform-up-and-running-locks"
   # encrypt = true
  #}
#}