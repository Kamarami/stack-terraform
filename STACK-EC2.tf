terraform{
  backend "s3"{
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
    bucket= "stackbuckstatemohamed1"
    key = "terraform.tfstate"
    region="us-east-1"
    dynamodb_table="statelock-tf"
  }
}