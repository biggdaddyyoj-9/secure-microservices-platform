terraform {
  backend "s3" {
    bucket         = "secure-microservices-tfstate" #Name of the S3 bucket where Terraform will store the remote state file.
    key            = "envs/dev/terraform.tfstate"   #Path within the bucket to store the state file, allows seperation by env (e.g prod, stag, dev, test)
    region         = "us-east-2"                    #AWS region where the S3 bucket is located, Must match the actual region of the bucket, not necessarily your infrastructure
    use_lockfile   = true                           #Enables state locking to prevent concurrent applies, Requires a DynamoDB table if you want full locking support.
    encrypt        = true                           #Ensures the state file is encrypted at rest using S3 server-side encryption.
    dynamodb_table = "terraform-locks"              #Enables state locking using this DynamoDB table to prevent concurrent Terraform operations

  }
}
