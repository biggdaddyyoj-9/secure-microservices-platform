Secure Microservices Platform with Terraform, Helm & AWS EKS

Project Overview

Project Overview

This project delivers a secure, production-grade microservices platform on AWS EKS, built from scratch using Terraform and Helm. It reflects real-world DevSecOps workflows, emphasizing automation, observability, and security-first infrastructure.

Infrastructure is provisioned with modular Terraform, featuring dynamic VPC, IAM, and EKS modules. State is managed via S3 and DynamoDB with locking and versioning. Teardown scripts ensure frictionless cleanup and future-proof migrations.

The Kubernetes platform is enhanced with Helm-deployed add-ons including:

-   Istio for mTLS and traffic routing
-   OAuth2 SSO Proxy for secure ingress
-   EFK stack for centralized logging
-   Prometheus for metrics collections
    - Grafana for Visualization & alerting
-   Sealed Secrets for secret delivery

Security is enforced through:
-   RBAC and NetworkPolicies
-   IRSA (IAM Roles for Service Accounts)
-   Policy-as-Code via Kyverno

CI/CD pipelines integrate Trivy vulnerability scans into build → scan → deploy stages using GitHub Actions. Infrastructure and application code are fully version-controlled and documented.

Two lightweight Python Flask microservices demonstrate:

-   Istio routing & canary rollouts
-   Centralized logging and metrics
-   Integration testing with pytest
-   Secure deployment workflows

1 - Architecture 

Infrastructure (Terraform)

    AWS VPC with 3 public and 3 private subnets across multiple AZs

    IAM roles for nodes, CI/CD pipelines, and restricted service accounts

    EKS cluster with managed node groups (RHEL or Bottlerocket for hardened nodes)

    Private endpoint access to limit public control plane exposure

    Modular Terraform structure with remote state locking via S3 + DynamoDB

Platform Add-ons (Helm) 

    Istio Service mesh with mTLS for service to service encryption 

    OAUTH2 Proxy integrated with an IdP for SSO 

    EFK stack (Elasticsearch, FluentBit, Kibana) for logging 

    Sealed secrets for secure Kubernetes secret delivery 

    Prometheus + Grafana for monitoring 

Security/Compliance 

    Namespace-level multi-tenancy with RBAC, LimitRanges, and NetworkPolicies. 

    IRSA (IAM Roles for Service Accounts) to enforce least privilege at pod level

    Admission control via Kyverno

    Trivy scans in CI/CD pipeline. 

    Node hardening via Ansible STIG baseline (ssh lockdown, auditd, sysctl). 

CI/CD (GitLab or GitHub Actions) 

    Build → Scan → Push → Deploy stages. 

    Trivy for container image scanning. 

    SonarQube (optional) for code quality. 

    Helm-based deployments with optional GitOps via ArgoCD  

Demo Apps (Python microservices) 

    Two lightweight Flask/FastAPI services (service-a & service-b) 

    Service A -> calls Service B (via HTTP) 

    Deploy via Helm charts in helm-charts/apps/ 

    Demonstrates: 
        Istio routing/canary rollouts
        
        logging (EFK) monitoring (Prometheus/Grafana)
    
        sealed secrets for secure config delivery

Testing (python) 

    Pytest integration tests run in CI/CD 

    Example: Validate /hello endpoint and inter-service communication

    Python used for:
        Microservice development
        CI/CD test automation
