resource "aws_efs_file_system" "EFS-mount" {
  tags = {
    Name = "EFS-mount"
  }
}

terraform{
  backend "s3"{
    bucket= "stackbuckstatemohamed"
    key = "terraform.tfstate"
    region= "us-east-1"
    dynamodb_table="statelock-tf"
  }
}

