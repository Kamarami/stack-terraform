terraform{
  backend "s3"{
    bucket= "stackbuckstatemohamed"
    key = "terraform.tfstate"
    region= "us-east-1"
    dynamodb_table="statelock-tf"
  }
}

