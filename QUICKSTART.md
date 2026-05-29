# Quick Start Guide - Azure Container Apps

## Option 1: Azure Cloud Shell (Easiest - No Docker!) ☁️

```bash
# 1. Go to https://shell.azure.com

# 2. First-time only: Register providers (if needed)
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
# Wait 1-2 minutes for registration to complete

# 3. Clone and navigate
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container

# 4. Deploy (change 'yourname' to something unique)
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus
```

**Done!** Your app will be at: `https://ssl-saas-demo-yourname.westus.azurecontainerapps.io`

**See**: `CLOUD_SHELL_DEPLOY.md` for detailed guide

---

## Option 2: Local Deployment (Requires Docker)

### Prerequisites
- Docker installed and running
- Azure CLI installed
- Azure subscription

### Deploy in 3 Commands

```bash
# 1. Login to Azure
az login

# 2. Clone and navigate
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container

# 3. Deploy (change 'yourname' to something unique)
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

**Done!** Your app will be at: `https://ssl-saas-demo-yourname.westus.azurecontainerapps.io`

---

## Local Development

```bash
# Run with Docker Compose
docker-compose up

# Open browser
open http://localhost:8080
```

## Update Deployment

```bash
# Make your code changes, then redeploy
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

## View Logs

```bash
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow
```

## Delete Everything

```bash
az group delete --name ssl-saas-demo-yourname-rg --yes
```

## Common Issues

**Docker not running**
```bash
# Start Docker Desktop, then verify
docker ps
```

**Azure login expired**
```bash
az login
```

**App name already taken**
```bash
# Use a more unique name
./deploy-container-app.sh ssl-saas-demo-yourcompany-yourname westus
```

## What Gets Created

1. Resource Group: `ssl-saas-demo-yourname-rg`
2. Container Registry: `sslsaasdemoYournameacr`
3. Container Apps Environment: `ssl-saas-demo-yourname-env`
4. Container App: `ssl-saas-demo-yourname`

## Next Steps

See `README.md` for:
- Custom domain configuration
- Cloudflare SSL for SaaS setup
- Detailed troubleshooting
- API documentation
