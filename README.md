Secure Microservices Platform with OpenShift, Helm & Terraform 

Project Overview

This project delivers a production-like Secure Microservices Platform on AWS EKS. Infrastructure is provisioned with Terraform and hardened using Ansible STIG baselines for RHEL/Bottlerocket worker nodes. 

The Kubernetes platform is enhanced with Helm-deployed add-ons including Istio (mTLS), OAuth2 SSO proxy, EFK logging, Prometheus/Grafana monitoring, and Sealed Secrets for encrypted secret delivery. 

Security is enforced through RBAC, NetworkPolicies, IRSA, and policy controls via Kyverno/Gatekeeper. A GitLab/GitHub CI/CD pipeline integrates Trivy scans into build→scan→deploy stages. 

Two lightweight Python Flask microservices demonstrate Istio routing, canary rollouts, centralized observability, and pytest-based integration testing—showcasing the full DevSecOps lifecycle from infrastructure to secure application delivery.


1 - Architecture 

Infra: Terraform 

    AWS VPC 3 public & 3 private subnets across AZs 

    IAM roles for nodes, CI/CD, & restricted service accounts 

    EKS cluster with managed node groups (RHEL based or Bottlerocker for security) 

    Private endpoint access (limit public control plane exposure) 

Platform Add-ons (Helm) 

    Istio Service mesh with mTLS for service-to-service encryption 

    OAUTH2 Proxy integrated with an IdP for SSO 

    EFK stack (Elasticsearch, FluentBit, Kibana) for logging 

    Sealed secrets for secure Kubernetes secret delivery 

    Prometheus + Grafana for monitoring 

Security/Compliance 

    Namespace-level multi-tenancy with RBAC, LimitRanges, and NetworkPolicies. 

    Trivy scans in CI/CD pipeline. 

    OPA Gatekeeper or Kyverno for admission control. 

    IAM Roles for Service Accounts (IRSA) to limit pod-level permissions. 

    Node hardening via Ansible STIG baseline (ssh lockdown, auditd, sysctl). 

CI/CD (GitLab or GitHub Actions) 

    Build → Scan → Push → Deploy stages. 

    Trivy for container image scanning. 

    SonarQube (optional) for code quality. 

    Deploy apps with Helm charts via GitOps (ArgoCD optional bonus). 

Demo Apps (Python microservices) 

    Two lightweight Flask/FastAPI services (service-a & service-b) 

    Service A -> calls Service B (via HTTP) 

    Deploy via Helm charts in helm-charts/apps/ 

    Used to demonstrate Istio routing, logging (EFK), monitoring (Prometheus/Grafana), sealed secrets 

Testing (python) 

    Pytest integration tests run in CI/CD 

    Example: Check /hello works, and Service A successfully calls Service B 

Python showcased in  

    App Development (Flask Services) 

    CI/CD Testing (pytest stage) 

 