terraform{
  backend "s3"{
    bucket= "stackbuckstatemohamed2"
    key = "terraform.tfstate"
    region="us-east-1"
    dynamodb_table="statelock-tf"
    profile = "default"
    access_key = "AKIAYWH4KYIQMIGGM236"
    secret_key = "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"
  }
}