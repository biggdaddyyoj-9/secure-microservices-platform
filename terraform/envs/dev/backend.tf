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

#S3: object storage
#Dynamodb: Nosql database

# What is backend.tf doing?
      # backend.tf file in Terraform defines where and how Terraform stores its state file
      # Terraform state is a JSON file that maps real-world resources to your configuration, tracks metadata,      
      # Allows Terraform to know what changes to apply
      # Prevents accidental destruction or duplication
      # By default, this state is stored locally, but that’s risky

# Benefits of Using backend.tf
      # S3 stores your state in one place, accessible to all team members and automation tools.
      # Highly durable (99.9%)  versioned if enabled, can roll back to previous states

      # can control access using IAM policies.
      # Encryption at rest (SSE-S3 or SSE-KMS) protects sensitive data like resource IDs and secrets.
      # works with gitlb CI/CD


# Why does terraform use state locking?
      # Prevents multiple people from running terraform apply at same time which could corrupt infrastructure
      # ensures only one terraform apply or plan can run at a time, avoids race conditions, duplicate resources, partial deployments
      # CI/CD pipelines/team don't accidentally overwrite eachothers changes


# What is LockID and where is it used?
      # It’s the primary key in your DynamoDB table, used to track and enforce a lock on state file

# What gets populated into DynamoDB?
      # When you run terraform apply terraform writes a lock entry into the table with the following

          #  Attribute:        Value:
          #  LockID            "envs/dev/terraform.tfstate"
          #  Info              JSON blob with metadata (who locked it, when, operation type)
          #  Operation         apply or plan
          #  CreatedTime       Timestam of when the lock was created

# The key field:
    # "envs/dev/terraform.tfstate" is the path to the state file inside the S3 bucket.
    # It’s like saying: “Store my state file in the envs/dev/ folder of the bucket, and name it terraform.tfstate.

# Why This Matters, this lets me:
    # Use one DynamoDB table for multiple environments Each environment (e.g., envs/dev, envs/prod) gets its own unique lock.
    # Avoid collisions If someone is working on envs/dev, they won’t block changes to envs/prod.


#  Visual Workflow
    # Here’s what happens when you run terraform apply:
    # Terraform reads your backend config.
    # It sees key = envs/dev/terraform.tfstate.
    # It tries to write a lock to DynamoDB:
#json
# {
  # "LockID": "envs/dev/terraform.tfstate",
  # "Info": { ...metadata... }
# }
    # If no lock exists → apply proceeds.
    # If a lock exists → apply fails with a lock error

# Does dynamodb table reside in s3?
  # no, it's seperate s3 holds terraform.tfstate in object storage(basically in filesystem in cloud)
  # dynamodb stores the lock metadata to prevent concurrent state changes (attributes/values) in NoSql db(key-value store)