terraform {                                         # Starts the Terraform configuration block. This is where you define settings that apply to the whole project.
  backend "s3" {
    bucket         = "secure-microservices-tfstate" # Name of the S3 bucket where Terraform will store the remote state file.
    key            = "envs/dev/terraform.tfstate"   # Path within the bucket to store the state file, allows seperation by env (e.g prod, stag, dev, test)
    region         = "us-east-2"                    # AWS region where the S3 bucket is located, Must match the actual region of the bucket, not necessarily your infrastructure
    use_lockfile   = true                           # Telling Terraform to create and maintain a .terraform.lock.hcl that tracks provider versions, think provider version locking, not state file concurrency
    encrypt        = true                           # Ensures the state file is encrypted at rest using S3 server-side encryption. not terribly neccessary since ss encryption was toggled at setup but its best practice 
    dynamodb_table = "terraform-locks"              # Tells Terraform to use dynamodb table "terraform-locks"
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

# What is LockID and where is it used?
      # When u configure: dynamodb_table = "terraform-locks"
      # Terraform expects us to have one primary key named LockID which 
      # acts as a unique identifier for each Terraform state file lock

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
    # when I run terraform apply:
    # Terraform checks remote backend (s3 + dynamodb) to check that nobody else is modifying state file @ same time
    # Terraform creates a unique lockid e.g: 3a5d7b21-9e4c-4bc3-9c22-4b71fbe49b9a
    # It tries to write a lock entry to DynamoDB table:

#json
# {
  #  "LockID": "3a5d7b21-9e4c-4bc3-9c22-4b71fbe49b9a",
  #  "Info": "terraform state lock",
  #  "Operation": "OperationTypeApply",
  #  "Who": "john@terraform",
  #  "Created": "2025-10-23T22:12:54Z"

# }

  # while this above record exists any other terraform plan or apply 
  # targeting the same s3 sate file will fail with lock error like

  #   Error: Error acquiring the state lock
  #   Lock Info:
  #   ID: 3a5d7b21-9e4c-4bc3-9c22-4b71fbe49b9a
  #   Operation: OperationTypeApply

# Does dynamodb table reside in s3?
  # no, it's seperate s3 holds terraform.tfstate in object storage(basically in filesystem in cloud)
  # dynamodb stores the lock metadata to prevent concurrent state changes (attributes/values) in NoSql db(key-value store)


# Terraform uses Amazon S3 to store its state file, which is a JSON document that maps real-world 
# infrastructure (like EC2 instances, VPCs, IAM roles) to the configuration defined in your 
# code. S3 acts as remote object storage—similar to a cloud-based file system—ensuring 
# durability, accessibility, and versioning.
# To prevent concurrent modifications to the state file, Terraform uses DynamoDB as a 
# locking mechanism. DynamoDB is a fully managed NoSQL database that stores lock entries. 
# Each lock entry includes attributes like: (See above)

# When a user runs terraform apply, Terraform first checks the DynamoDB table to see if a 
# lock already exists for the state file. If a lock is present, the operation fails to 
# prevent conflicts. If no lock exists, Terraform writes a new lock entry, proceeds with 
# the apply, and then updates the state file in S3. Once the operation completes, 
# the lock is released.
