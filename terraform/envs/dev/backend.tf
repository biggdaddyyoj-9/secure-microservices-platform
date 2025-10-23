terraform {
  backend "s3" {
    bucket         = "secure-microservices-tfstate"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}
