Ride-Sharing Platform SRE Architecture

This repository contains a production-grade, microservices-based architecture for a global ride-sharing platform. It was architected with a focus on Security, Scalability, and Automation.

Architecture Overview

Infrastructure: AWS EKS (Kubernetes) managed via Terraform.

Security: Private-subnet node deployment with automated security scanning via Checkov.

Orchestration: Multi-service deployment managed by Helm.

CI/CD: Full automation using GitHub Actions, performing validation, linting, and security audits on every push.

Key Engineering Challenges Solved

Infrastructure Security: Implemented private-subnet EKS clusters to reduce attack surface, resolving node registration complexities through optimized VPC routing.

GitOps Workflow: Eliminated manual provisioning by moving infrastructure management to a CI/CD pipeline, ensuring consistent and reproducible environments.

Automated Compliance: Integrated "Shift-Left" security scanning to proactively detect misconfigurations before deployment.

CI/CD Pipeline

Every commit triggers:

Terraform Validate: Ensures infrastructure as code is syntactically correct.

Helm Lint: Ensures deployment templates are valid.

Security Audit: Scans for cloud security misconfigurations using Checkov.

Built as a scalable reference architecture for high-availability SRE environments.