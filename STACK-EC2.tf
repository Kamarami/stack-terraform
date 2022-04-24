#Initialize the backend and use s3 to store statefile
terraform{
  backend "s3"{
    bucket= "stackbuckstatemohamed2"
    key = "terraform.tfstate"
    region="us-east-1"
    dynamodb_table="statelock-tf"
    profile = "default"
  }
}
#Create EC2 instance
#Create EFS
#Mount EFS to EC2 instance