# 📝 Multi-App Django Platform

A containerized Django 5.1 development platform featuring integrated applications for content management, utilities, and task tracking. This project is configured with a complete DevOps lifecycle, including Dockerization, Kubernetes orchestration, and CI/CD pipelines.

## 🚀 Key Applications

- **Blogging App (`posts`):** A content management system supporting image uploads (via Pillow), slug-based routing, and author-attributed posts.
- **Calculator (`game`):** A web-based utility for performing basic arithmetic operations.
- **Users App (`users`):** A secure authentication layer handling user registration, login, and session management using Django's built-in security features.

## 🛠️ Tech Stack

- **Backend:** Django 5.1.1
- **Database:** SQLite 3
- **Environment:** Python 3.12 (Alpine)
- **Orchestration:** Kubernetes
- **Web Server:** NGINX with SSL (Let's Encrypt)

## 📂 Infrastructure & DevOps

This repository includes several professional-grade deployment configurations:
- **Multi-Stage Builds:** `Docker-multi` uses a build-base stage to compile dependencies, resulting in a significantly smaller final production image.
- **Kubernetes Manifests:** Includes `deployment.yml`, `service.yml`, and `namespace.yml` for deploying the application into a dedicated `django` namespace.
- **CI/CD Pipelines:** GitHub Actions workflows (`docker-image.yml` and `ec2-deploy.yml`) automate the process of building images for DockerHub and deploying them to AWS EC2 via SSH.
- **NGINX Proxy:** A pre-configured `webdomain` file for NGINX handles reverse proxying to port 8000 and enforces HTTPS redirection.

## 🏁 Getting Started

### Local Setup
1. **Initialize Environment:**
```bash
python -m venv .venv
source .venv/Scripts/activate  # For Git Bash/MINGW64
pip install -r blogging-app/requirements.txt
```
   
2. **Database & Execution:**
```bash
python blogging-app/manage.py migrate
python blogging-app/manage.py runserver
```

3. **Docker Execution**
**To run the application using the optimized Alpine configuration:**
```bash
docker build . -t django-blog -f Docker-alpine
docker run -d -p 8000:8000 django-blog
```

## ⚙️ CI/CD Configuration
***To utilize the automated deployment workflows, ensure the following GitHub Secrets are set:***

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
- EC2_SSH_KEY
- REMOTE_HOST (Your EC2 Public IP)
