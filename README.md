## Phase 1: Infrastructure (Terraform) 
- VPC, subnets, NAT Gateway: isolates workloads and enables secure outbound traffic 
- IAM roles/policies: scoped access for EKS nodes, and CI/CD 
- EKS cluster with node groups: scalable managed Kubernetes backbone 
- S3 buckets for remote state and locking: ensures safe, auditable Terraform workflows 
 
## Phase 2: Microservices (Python) 
- Containerized with Dockerfiles: scoped, reproducible builds 
- Pushed to ECR: private, secure registry 
- Tests in tests/test_services.py: unit + integration coverage 
- Validated locally: curl, logs, metrics — all confirmed 
- Inter-service routing: /call-b hits /ping - via Kubernetes DNS 
- Structured logging + Prometheus metrics: observability locked in 
 
## Phase 3: Deployment (Helm) 
- Helm charts per service: modular, environment-aware 
- values.yaml for config injection: clean separation of concerns 
- helm install or helm upgrade: declarative, repeatable deployments 
 
## Phase 4: Monitoring & Logging 
- Prometheus + Grafana: metrics and dashboards confirmed 
- Loki + Promtail: structured logs flowing and visualized 
- Kyverno validates Kubernetes maifiests
 
## Phase 5: CI/CD (GitLab) 
- .gitlab-ci.yml pipeline: 
- Build and push Docker images 
- Run pytest tests 
- Scan with Trivy 
- Deploy with Helm # Trigger pipeline
 
 
