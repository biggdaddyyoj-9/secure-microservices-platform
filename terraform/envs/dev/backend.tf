terraform {
  backend "s3" {
    bucket = "secure-microservices-tfstate"
    key    = "envs/dev/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks" #name
  }
}
