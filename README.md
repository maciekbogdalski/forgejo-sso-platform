# Forgejo SSO Platform

This repository contains a comprehensive project for automating the deployment of a scalable Forgejo instance with Single Sign-On (SSO) capabilities. The project was developed as part of the "Virtualization and Cloud Computing" course exam and replicates real-world DevOps practices using modern tools and technologies.

## Project Overview

The project involves the following key components:

- **Automated Deployment**: The setup of the entire environment is automated using Ansible, ensuring that the deployment is reproducible, scalable, and requires no manual intervention.
- **Docker Swarm**: A Docker Swarm cluster is configured to orchestrate the deployment of multiple services across nodes, including Forgejo, Keycloak (for SSO) and Prometheus (for metrics collection).
- **Centralized Monitoring**: Integration of Prometheus to monitor system health and performance, with persistent storage to ensure data resilience.
- **Secure and Scalable Configuration**: Secure communications are implemented using self-signed certificates, with Traefik handling reverse proxying and TLS termination.

## Key Features

- **Scalability**: The Docker Swarm setup is easily extendable, supporting the addition of multiple worker nodes and horizontal service scaling.
- **Security**: Secure SSO implementation via Keycloak, with HTTPS encryption for all services.
- **Persistence**: Data persistence is ensured across service restarts and node failures using NFS and Docker Swarm's built-in features.
- **Monitoring and Metrics**: Full-stack monitoring is provided by Prometheus, offering detailed insights into the infrastructure.

## Technologies Used

- **Ansible**: For automating the setup and configuration of the entire environment.
- **Docker Swarm**: For orchestrating containerized services across multiple nodes.
- **Traefik**: As a reverse proxy and load balancer, managing incoming traffic with TLS encryption.
- **Keycloak**: For Single Sign-On (SSO) and identity management.
- **Prometheus**: For monitoring, metrics collection, and visualization.

## Setup Instructions

To set up the project on your local machine:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/forgejo-sso-platform.git
   ```
2. **Navigate to the Project Directory**:
   ```bash
   cd forgejo-sso-platform
   ```
3. **Run the Setup**:
   ```bash
   make setup-all
   ```

This will automatically deploy and configure all services on two Ubuntu 22.04 VMs.

## Accessing the Services

- **Forgejo**: `https://git.vcc.local`
- **Keycloak**: `https://auth.vcc.local`
- **Prometheus**: `https://prom.vcc.local`

## Challenges and Solutions

This project involved tackling several complex challenges, such as seamless service integration, automated certificate management, and maintaining persistent storage across distributed nodes. These were addressed through advanced Docker Swarm configurations, custom Ansible playbooks, and the integration of comprehensive monitoring tools to ensure system reliability and performance.

## Repository Structure

- **playbooks/**: Ansible playbooks for automating the setup.
- **docker/**: Custom Dockerfiles and configurations for the deployed services.
- **templates/**: Configuration templates for various services.
- **docs/**: Documentation on the setup, configuration, and usage of the system.
