terraform{
  backend "s3"{
    AWS_ACCESS_KEY="AKIAYWH4KYIQMIGGM236"
    AWS_SECRET_KEY="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"
    bucket= "stackbuckstatemohamed1"
    key = "terraform.tfstate"
    region="us-east-1"
    dynamodb_table="statelock-tf"
  }
}