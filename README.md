# Secure Microservices Platform on AWS EKS

## Project Overview

This project delivers a secure, production level microservices platform on AWS EKS using Terraform, Python, Helm, and GitLab CI/CD. It follows a phased DevSecOps workflow with infrastructure as code, containerized microservices, and policy driven security.

---

## Phase 1: Infrastructure (Terraform)

Provision core cloud infrastructure using Terraform:

- VPC with public/private subnets across multiple AZs
- IAM roles for EKS, EC2 nodes, and CI/CD pipelines
- EKS cluster with managed node groups
- NAT Gateway for private subnet access
- S3 for remote state locking and versioning


---

## Phase 2: Microservices (Python)

Develop and containerize lightweight Python services:

- `apps/service-a` and `apps/service-b` using FastAPI or Flask
- Dockerfiles for each service
- Push images to ECR or Docker Hub
- Write unit/integration tests in `tests/test_services.py`
- Validate locally, then deploy to EKS

---

## Phase 3: Deployment (Helm)

Deploy services to Kubernetes using Helm:

- Create Helm charts for each service
- Use `values.yaml` for environment-specific configs
- Deploy with:
  ```bash
  helm install service-a ./helm-charts/service-a

## Phase 4: Configuration Management (Ansible)

Automate post-deployment configuration:

- Install monitoring agents (Prometheus, Grafana)
- Configure S3/DynamoDB access policies
- Patch EC2 instances or bastion hosts

## Phase 5: Security & Observability

Enforce security and monitor workloads:

- Kyverno for policy enforcement (e.g., block privileged pods)
- Trivy for container image scanning
- Sealed Secrets for encrypted secret delivery
- Prometheus + Grafana for metrics and dashboards

## Phase 6: CI/CD (GitLab)

Automate build, test, and deploy workflows:

- Use ci-cd/pipeline.yml to:
- Build and push Docker images
- Run pytest
- Scan with Trivy
- Deploy via Helm
- Enforce policies with Kyverno

## Testing

Pytest integration tests validate endpoints and 

- inter-service communication
- Example: /hello endpoint in service-a
- Python used for:
- Microservice development
- CI/CD test automation

## Demo Apps
- Two lightweight Python services:
- service-a → exposes /hello and calls service-b
- service-b → responds to internal requests
- Deployed via Helm charts in helm-charts/service-a and    helm-charts/service-b
