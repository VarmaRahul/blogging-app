# 📝 Multi-App Django Platform

A containerized Django 5.1 development platform featuring integrated applications for content management, utilities, and user authentication. This project is configured with a complete DevSecOps and GitOps lifecycle, including multi-stage Docker builds, automated security scanning, Kubernetes orchestration on `kind` (Podman Desktop), and continuous deployment via Argo CD.

## 🚀 Key Applications

- **Blogging App (`posts`):** A content management system supporting image uploads (via Pillow), slug-based routing, and author-attributed posts.
- **Calculator (`game`):** A web-based utility for performing basic arithmetic operations.
- **Users App (`users`):** A secure authentication layer handling user registration, login, and session management using Django's built-in security features.

## 🛠️ Tech Stack

- **Backend:** Django 5.1.1 & Gunicorn
- **Database:** PostgreSQL 15
- **Containerization:** Python 3.12 (Multi-stage Alpine) & Docker Compose
- **Orchestration:** Kubernetes (`kind` via Podman Desktop)
- **GitOps & CI/CD:** Argo CD & GitHub Actions (Hadolint, Gitleaks, CodeQL, `pip-audit`, Trivy, Dependabot)

## 📂 Repository & GitOps Architecture

```text
blogging-app/
├── .github/
│   ├── dependabot.yml              # Weekly dependency & container base image updates
│   └── workflows/
│       └── pipeline.yaml           # DevSecOps CI & GitOps manifest updater
├── app/                            # Django application source code
├── deployment/
│   ├── argocd-app.yaml             # Argo CD Application manifest
│   └── k8s/                        # Kubernetes manifests watched by Argo CD
│       ├── namespace.yaml          # 'blogging' namespace
│       ├── secret.yaml             # Application & PostgreSQL credentials
│       ├── postgres.yaml           # PostgreSQL 15 PVC, Deployment & 'db' Service
│       └── web.yaml                # Gunicorn Deployment (with DB initContainer) & Service
├── .env.docker                     # Docker Compose environment variables
├── .env.local                      # Local development environment variables
├── docker-compose.yml              # Local Docker Compose setup
├── Dockerfile                      # Multi-stage Python 3.12 Alpine image
└── requirements.txt                # Python dependencies
```

### Infrastructure & DevSecOps Highlights

- **Multi-Stage Builds:** `Dockerfile` uses a builder stage to compile wheels before copying runtime dependencies into a slim Alpine image running as a non-root user (`appuser`).
- **Automated DevSecOps CI (`.github/workflows/pipeline.yaml`):** Runs Dockerfile linting (Hadolint), secret detection (Gitleaks), SAST (CodeQL), dependency auditing (`pip-audit`), and container vulnerability scanning (Trivy) before pushing versioned images (`xedose/blogging-app:v1.0.<run_number>`) to Docker Hub.
- **GitOps Continuous Delivery (`deployment/`):** CI automatically updates the image tag in `deployment/k8s/web.yaml` (`[skip ci]`), and Argo CD continuously syncs the manifests into the `blogging` namespace on the local `kind` cluster.
- **Automated Dependency Maintenance (`.github/dependabot.yml`):** Checks `pip`, `github-actions`, `Dockerfile`, and Kubernetes manifest base images (`postgres:15`, `busybox:1.36`) weekly.

---

## 🏁 Getting Started

### 1. Local Python Setup

1. **Initialize Environment:**
   ```bash
   python -m venv .venv
   source .venv/Scripts/activate  # For Git Bash / MINGW64
   pip install -r requirements.txt
   ```

2. **Database & Execution:**
   ```bash
   python app/manage.py migrate
   python app/manage.py runserver
   ```
   Open **`http://127.0.0.1:8000`** in your browser.

### 2. Local Docker Compose Setup

To run Django and PostgreSQL 15 together locally using `.env.docker`:
```bash
docker compose up --build
```
Open **`http://localhost:8000`** in your browser.

---

## ☸️ Local Kubernetes (`kind`) & Argo CD Deployment

### Step 1: Verify Cluster Context

Switch `kubectl` to your local `kind` cluster running in Podman Desktop and confirm the node is ready:
```bash
kubectl config use-context kind-kind-cluster
kubectl get nodes
```

### Step 2: Install & Access Argo CD

Create the `argocd` namespace and install Argo CD:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
kubectl get all -n argocd
```

*(Optional)* Scale down `argocd-applicationset-controller` on local setups to conserve memory when using standard `Application` manifests:
```bash
kubectl scale deployment argocd-applicationset-controller -n argocd --replicas=0
```

Retrieve the initial `admin` password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Forward port `443` to `8080` (either via CLI or Podman Desktop's **Kubernetes → Services → `argocd-server` → Port Forwarding** UI):
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Log in at **`https://localhost:8080`** using username `admin` and the decoded password.

### Step 3: Deploy the Application via Argo CD

Register the declarative Argo CD `Application` manifest:
```bash
kubectl apply -f deployment/argocd-app.yaml
```

Verify that Argo CD creates the `blogging` namespace, provisions PostgreSQL (`db`), waits for port `5432` via the `initContainer`, runs `python manage.py migrate`, and starts the Gunicorn web server:
```bash
kubectl get applications -n argocd
kubectl get all -n blogging
```

### Step 4: Access the Live Application

Port-forward `blogging-web-service` to local port `8000` (via Podman Desktop UI or CLI):
```bash
kubectl port-forward svc/blogging-web-service -n blogging 8000:8000
```
Open **`http://localhost:8000`** in your browser.

### Step 5: Cleanup

To remove the application and all managed Kubernetes resources from the cluster:
```bash
kubectl delete application blogging-app -n argocd
```

If a namespace remains orphaned after a non-cascading delete:
```bash
kubectl delete namespace blogging
```

---

## ⚙️ CI/CD Configuration

Ensure the following GitHub Repository Secrets are configured under **Settings → Secrets and variables → Actions** for `.github/workflows/pipeline.yaml`:

| Secret Name | Description |
| :--- | :--- |
| `DOCKERHUB_USERNAME` | Your Docker Hub username (`xedose`) |
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token with Read & Write permissions |