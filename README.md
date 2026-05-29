# SSL for SaaS Demo - Azure Container Apps

Node.js app demonstrating Cloudflare SSL for SaaS by displaying HTTP headers, TLS info, and SNI details.

**GitHub**: https://github.com/adz80/sample-azure-app-container

---

## Quick Deploy

### Cloud Shell (No Docker Required!)

Go to **https://shell.azure.com** and run:

```bash
# First time only - register providers
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Clone and deploy
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus
```

**Done!** Your app: `https://ssl-saas-demo-yourname.westus.azurecontainerapps.io`

### Local Deploy (Requires Docker)

```bash
az login
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

---

## Local Development

```bash
# Run with Docker Compose
docker-compose up

# Or run directly
npm install
npm start
```

Open `http://localhost:8080`

---

## Common Commands

**View logs:**
```bash
az containerapp logs show --name ssl-saas-demo-yourname --resource-group ssl-saas-demo-yourname-rg --follow
```

**Update app:**
```bash
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus
```

**Delete everything:**
```bash
az group delete --name ssl-saas-demo-yourname-rg --yes
```

---

## Cloudflare SSL for SaaS Setup

### 1. Get Container App URL

```bash
az containerapp show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --query properties.configuration.ingress.fqdn -o tsv
```

### 2. Add Custom Domain in Azure

1. Go to Azure Portal → Container App → **Custom domains**
2. Click **+ Add custom domain**
3. Enter your domain (e.g., `demo.example.com`)
4. Create DNS CNAME: `demo.example.com → [container-app-url]`
5. Validate and add
6. Choose managed certificate

### 3. Configure Cloudflare SSL for SaaS

1. Go to Cloudflare Dashboard → **SSL/TLS** → **Custom Hostnames**
2. Click **Add Custom Hostname**
3. Enter customer domain: `customer.example.com`
4. Choose SSL certificate (Let's Encrypt)
5. Create DNS CNAME: `customer.example.com → [container-app-url]`
6. Enable Cloudflare proxy (orange cloud)

### 4. Add Customer Domain to Azure

1. Go to Azure Portal → Container App → **Custom domains**
2. Add `customer.example.com`
3. Validate and add

### 5. Test

- **Direct**: `https://ssl-saas-demo-yourname.westus.azurecontainerapps.io` (no CF headers)
- **Custom domain**: `https://demo.example.com` (Azure headers)
- **SSL for SaaS**: `https://customer.example.com` (CF headers visible!)

---

## Architecture

```
Client Browser
    ↓
Cloudflare Edge (TLS termination, adds CF-* headers)
    ↓
Azure Container Apps Ingress (TLS re-termination)
    ↓
Docker Container (Node.js app captures all headers)
```

---

## Troubleshooting

**MissingSubscriptionRegistration error:**
```bash
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
# Wait 1-2 minutes
```

**Docker not running:**
```bash
docker ps  # Verify Docker is running
```

**App name already taken:**
```bash
# Use a more unique name
./deploy-cloud-shell.sh ssl-saas-demo-mycompany-adam westus
```

**Try different region:**
```bash
./deploy-cloud-shell.sh ssl-saas-demo-adam eastus
# or westeurope, australiaeast, southeastasia
```

---

## API Reference

**Endpoints:**
- `GET /` - Web UI
- `GET /api/info` - JSON with all request data

**Response:**
```json
{
  "connection": {
    "method": "GET",
    "hostname": "customer.example.com",
    "timestamp": "2026-05-29T07:23:04.000Z"
  },
  "tls": {
    "sni": "customer.example.com",
    "protocol": "TLSv1.3",
    "cipher": "AEAD-AES128-GCM-SHA256"
  },
  "headers": {
    "cloudflare": { "cf-ray": "...", "cf-connecting-ip": "..." },
    "forwarded": { "x-forwarded-for": "...", "x-forwarded-proto": "https" },
    "azure": { "x-arr-log-id": "..." },
    "standard": { "host": "...", "user-agent": "..." }
  }
}
```

---

## What's Included

**Container:**
- `Dockerfile` - Multi-stage build, node:24-alpine (~150MB)
- `.dockerignore` - Build optimization
- `docker-compose.yml` - Local development

**Deployment:**
- `deploy-cloud-shell.sh` - Deploy from browser (no Docker)
- `deploy-container-app.sh` - Deploy locally (requires Docker)

**App:**
- `server.js` - Express server
- `public/` - Web UI
- `package.json` - Dependencies

---

## Features

- 🔒 TLS information display (SNI, protocol, cipher)
- 📡 HTTP headers inspector (organized by category)
- ☁️ Cloudflare headers detection (CF-*, X-Forwarded-*)
- 🌐 Azure headers display
- 📋 Copy to clipboard
- 🎨 Clean, responsive UI
- 🐳 Containerized (portable, scalable)

---

## Benefits

- **Portable**: Runs anywhere (local, Azure, any cloud)
- **Cost-effective**: ~$2-5/month (vs ~$13 for App Service)
- **Scale to zero**: Pay only when running
- **Modern**: Container-native, Kubernetes-based
- **Auto-scaling**: 1-10 replicas based on load

---

## Tech Stack

- Node.js 24 LTS
- Express
- Docker (Alpine Linux)
- Azure Container Apps
- Azure Container Registry
- Cloudflare SSL for SaaS

---

## License

MIT
