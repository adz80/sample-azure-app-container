# Azure Container Apps - SSL for SaaS Demo

A containerized Node.js application designed to demonstrate Cloudflare SSL for SaaS by displaying HTTP headers, TLS information, and SNI (Server Name Indication) details. Runs on Azure Container Apps with Docker.

**GitHub**: https://github.com/adz80/sample-azure-app-container

---

## 🚀 Quick Start - Deploy in 2 Steps

### Prerequisites

- Azure CLI installed ([install guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- Docker installed ([install guide](https://docs.docker.com/get-docker/))
- Azure subscription

### Step 1: Clone the Repository

```bash
# Clone the repo
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container

# Login to Azure
az login
```

### Step 2: Deploy to Azure Container Apps

```bash
# Deploy with one command (change app name to be unique)
./deploy-container-app.sh ssl-saas-demo-yourname westus

# Done! Wait 3-5 minutes for deployment
```

**Script Parameters:**
- First argument: App name (must be unique, lowercase, alphanumeric and hyphens only)
- Second argument: Azure region (default: westus)

**Alternative regions:**
- `westeurope`
- `australiaeast`
- `southeastasia`
- `eastus`

**Your app will be at**: `https://ssl-saas-demo-yourname.[region].azurecontainerapps.io`

**Deployment Scripts:**
- `deploy-cloud-shell.sh` - For Azure Cloud Shell (no Docker needed)
- `deploy-container-app.sh` - For local deployment (requires Docker)

Both scripts will:
1. ✅ Create resource group
2. ✅ Create Azure Container Registry (ACR)
3. ✅ Build Docker image (locally or in Azure)
4. ✅ Push image to ACR
5. ✅ Create Container Apps environment
6. ✅ Deploy your container app
7. ✅ Configure ingress and scaling

---

## ✨ Features

- 🔒 **TLS Information Display**: Shows SNI hostname, TLS protocol, and cipher suite
- 📡 **HTTP Headers Inspector**: Displays all incoming HTTP headers, organized by category
- ☁️ **Cloudflare Headers**: Highlights Cloudflare-specific headers (CF-*, X-Forwarded-*)
- 🌐 **Azure Headers**: Shows Azure Container Apps specific headers
- 📋 **Copy to Clipboard**: Easy export of all request data
- 🎨 **Clean Web UI**: Responsive interface perfect for live demos
- 🐳 **Containerized**: Portable, scalable, runs anywhere

---

## 🏗️ How It Works

This containerized application captures request information at the Azure Container Apps level. Since Azure terminates TLS at the ingress controller, the app reconstructs TLS information from headers provided by:

- **Cloudflare**: `CF-SSL-Protocol`, `CF-SSL-Cipher`, `CF-Visitor`
- **Azure**: `X-ARR-ClientCert`, `X-Forwarded-Proto`
- **Standard**: `Host`, `X-Forwarded-For`, `X-Forwarded-Host`

### Architecture

```
Client Browser
    ↓
Cloudflare Edge (TLS termination, adds CF-* headers)
    ↓
Azure Container Apps Ingress (TLS re-termination, adds X-Forwarded-* headers)
    ↓
Docker Container (Node.js Application captures all headers)
```

---

## 💻 Local Development

### Option 1: Docker (Recommended)

```bash
# Build and run with Docker Compose
docker-compose up

# Or build and run manually
docker build -t ssl-saas-demo .
docker run -p 8080:8080 ssl-saas-demo
```

Open your browser to `http://localhost:8080`

### Option 2: Node.js Directly

**Prerequisites:**
- Node.js 18.x or higher
- npm

```bash
# Install dependencies
npm install

# Run the application
npm start
```

Open your browser to `http://localhost:8080`

### Development Tips

- **Hot reload**: Mount volumes in docker-compose.yml (already configured)
- **View logs**: `docker-compose logs -f`
- **Rebuild**: `docker-compose up --build`
- **Stop**: `docker-compose down`

---

## ☁️ Cloudflare SSL for SaaS Setup

This demo shows how to use Cloudflare SSL for SaaS to provide custom domains for your customers.

**Prerequisites**: Deploy your Azure Container App first (see Quick Start above)

**Example domains used**:
- Azure custom domain: `demo.example.com`
- SSL for SaaS customer domain: `school1.schooldomain.edu`

### Step 1: Add Custom Domain in Azure Container Apps

Add a custom domain to your Azure Container App:

**Get your Container App FQDN**:
```bash
az containerapp show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --query properties.configuration.ingress.fqdn -o tsv
```

**Configure DNS**:
```
CNAME: demo.example.com → [container-app-fqdn from above]
```

**Add to Azure**:
1. Go to Azure Portal → Your Container App → **Custom domains**
2. Click **+ Add custom domain**
3. Enter `demo.example.com` (your domain)
4. Click **Validate** (Azure will verify the CNAME)
5. Once validated, click **Add**
6. Choose certificate (Managed certificate recommended)
7. Wait 1-2 minutes for domain to be added

### Step 2: Add SSL for SaaS Custom Hostname in Cloudflare

Add a customer domain through Cloudflare SSL for SaaS:

1. Go to Cloudflare Dashboard → **SSL/TLS** → **Custom Hostnames**
2. Click **Add Custom Hostname**
3. Enter customer domain: `school1.schooldomain.edu`
4. Choose SSL certificate option (e.g., **Let's Encrypt**)
5. Click **Add**
6. Wait for certificate to be issued (~1-2 minutes)

### Step 3: Configure DNS for SSL for SaaS Domain

Create a CNAME record for the customer domain pointing to your Container App FQDN:

```
CNAME: school1.schooldomain.edu → [container-app-fqdn]
```

Enable Cloudflare proxy (orange cloud) in DNS settings for automatic SSL.

### Step 4: Add SSL for SaaS Domain to Azure Container Apps

Add the customer domain to Azure Container Apps:

1. Go to Azure Portal → Your Container App → **Custom domains**
2. Click **+ Add custom domain**
3. Enter `school1.schooldomain.edu`
4. Click **Validate**
5. Once validated, click **Add**
6. Choose **Managed certificate** (or skip if Cloudflare handles SSL)
7. Wait for domain to be configured

### Step 5: Test the Demo

**Direct Access** (no Cloudflare):
- Visit `https://ssl-saas-demo-yourname.[region].azurecontainerapps.io`
- You'll see Azure Container Apps headers but no Cloudflare headers

**Azure Custom Domain**:
- Visit `https://demo.example.com`
- You'll see Azure headers
- SNI will show `demo.example.com`

**SSL for SaaS Domain** (through Cloudflare):
- Visit `https://school1.schooldomain.edu`
- You'll see Cloudflare headers: `CF-Ray`, `CF-Connecting-IP`, `CF-SSL-Protocol`, etc.
- SNI will show `school1.schooldomain.edu`
- This demonstrates multi-tenant SSL!

---

## 📊 Understanding the Headers

### Cloudflare Headers (CF-*)

| Header | Description | Example |
|--------|-------------|---------|
| `cf-ray` | Unique request identifier | `8a1b2c3d4e5f6789-SJC` |
| `cf-connecting-ip` | Original client IP address | `203.0.113.42` |
| `cf-visitor` | JSON with connection scheme | `{"scheme":"https"}` |
| `cf-ssl-protocol` | TLS version used | `TLSv1.3` |
| `cf-ssl-cipher` | Cipher suite | `AEAD-AES128-GCM-SHA256` |

### Azure Headers (X-ARR-*, X-MS-*, X-Forwarded-*)

| Header | Description | Example |
|--------|-------------|---------|
| `x-forwarded-for` | Client IP chain | `203.0.113.42` |
| `x-forwarded-proto` | Protocol used | `https` |
| `x-forwarded-host` | Original host header | `school1.schooldomain.edu` |
| `x-arr-clientcert` | Client certificate (if mTLS) | Base64 encoded cert |

### TLS Information Sources

- **SNI**: From `host` header or `x-forwarded-host`
- **TLS Protocol**: From `cf-ssl-protocol` (Cloudflare) or `x-forwarded-proto` (fallback)
- **Cipher Suite**: From `cf-ssl-cipher` (Cloudflare only)
- **Client Certificate**: From `x-arr-clientcert` (Azure, if mTLS enabled)

---

## 🎬 Demo Guide

### What to Show

**1. Direct Access**
- Open `https://ssl-saas-demo-yourname.[region].azurecontainerapps.io`
- Point out: "No Cloudflare headers - direct to Azure Container Apps"
- Show: TLS cipher is "N/A"

**2. Azure Custom Domain**
- Open `https://demo.example.com`
- Point out: "Custom domain on Azure Container Apps"
- Show: SNI changes to custom domain

**3. SSL for SaaS Domain**
- Open `https://school1.schooldomain.edu`
- Point out: "Now we see CF-* headers through Cloudflare!"
- Show: TLS protocol and cipher now visible
- Demonstrate: "This is a customer's domain with SSL"

**4. Multiple Domains**
- Open different SSL for SaaS domains (e.g., `school2.schooldomain.edu`)
- Show: SNI changes for each domain
- Demonstrate: "One app, many customer domains with individual SSL"

### Expected Output

**Direct Access** (`ssl-saas-demo-yourname.[region].azurecontainerapps.io`):
- ✅ Azure headers
- ❌ No Cloudflare headers
- SNI = `ssl-saas-demo-yourname.[region].azurecontainerapps.io`
- TLS cipher = "N/A"

**Azure Custom Domain** (`demo.example.com`):
- ✅ Azure headers
- ⚠️ May have Cloudflare headers if proxied
- SNI = `demo.example.com`

**SSL for SaaS Domain** (`school1.schooldomain.edu`):
- ✅ Azure headers
- ✅ Cloudflare headers (CF-Ray, CF-SSL-Protocol, etc.)
- ✅ TLS cipher visible
- SNI = `school1.schooldomain.edu`
- ⭐ This demonstrates multi-tenant SSL!

---

## 🔄 Update Your App

After making code changes:

```bash
# Rebuild and redeploy
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

The script will:
- Rebuild the Docker image
- Push to ACR
- Update the Container App with the new image

Or manually:

```bash
# Build and push
docker build -t ssl-saas-demo .
az acr login --name sslsaasdemoYournameacr
docker tag ssl-saas-demo sslsaasdemoYournameacr.azurecr.io/ssl-saas-demo:latest
docker push sslsaasdemoYournameacr.azurecr.io/ssl-saas-demo:latest

# Update container app
az containerapp update \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --image sslsaasdemoYournameacr.azurecr.io/ssl-saas-demo:latest
```

---

## 🆘 Troubleshooting

### Deployment Issues

**Docker not running**
- Start Docker Desktop or Docker daemon
- Verify: `docker ps`

**Azure CLI not logged in**
```bash
az login
az account show
```

**Quota error during deployment**
- Try different regions: `./deploy-container-app.sh myapp westeurope`
- Or request quota increase in Azure Portal → Subscriptions → Usage + quotas

**ACR name already taken**
- The script generates ACR name from app name
- Try a more unique app name

### Runtime Issues

**Container won't start**
```bash
# View logs
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow

# Check revision status
az containerapp revision list \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --output table
```

**No Cloudflare headers visible**
- You're accessing directly (not through Cloudflare)
- Ensure you're using the custom domain configured in SSL for SaaS
- Check DNS CNAME is correct
- Verify Cloudflare proxy is enabled (orange cloud)

**TLS info shows "N/A"**
- This is expected when accessing directly
- Cloudflare adds these headers when proxied

**Custom domain not working**
- Wait for DNS propagation (up to 48h, usually minutes)
- Verify CNAME points to Container App FQDN
- Check Azure custom domain is added and verified

### Useful Commands

```bash
# View logs (live tail)
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow

# Restart app
az containerapp revision restart \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg

# Get app URL
az containerapp show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --query properties.configuration.ingress.fqdn -o tsv

# Scale app
az containerapp update \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --min-replicas 0 \
  --max-replicas 10

# Delete everything (cleanup)
az group delete --name ssl-saas-demo-yourname-rg --yes
```

---

## 📡 API Reference

### Endpoints

- `GET /` - Web UI
- `GET /api/info` - JSON response with all request information

### Response Format

```json
{
  "connection": {
    "method": "GET",
    "url": "/api/info",
    "protocol": "https",
    "hostname": "customer.example.com",
    "timestamp": "2026-05-29T04:23:04.000Z"
  },
  "tls": {
    "sni": "customer.example.com",
    "protocol": "TLSv1.3",
    "cipher": "AEAD-AES128-GCM-SHA256",
    "clientCert": "Not present"
  },
  "headers": {
    "cloudflare": { ... },
    "forwarded": { ... },
    "azure": { ... },
    "standard": { ... },
    "all": { ... }
  }
}
```

---

## 🛠️ Technologies Used

- **Node.js 24 LTS**: Runtime environment
- **Express**: Web framework
- **Docker**: Containerization (node:24-alpine base image)
- **Azure Container Apps**: Hosting platform (Kubernetes-based)
- **Azure Container Registry**: Private Docker registry
- **Cloudflare SSL for SaaS**: SSL/TLS proxy and custom hostnames

---

## 🐳 Container Details

### Dockerfile

- **Base Image**: `node:24-alpine` (lightweight, secure, production-ready)
- **Multi-stage build**: Optimized for size and security
- **Non-root user**: Runs as `nodejs` user (UID 1001)
- **Port**: 8080
- **Size**: ~150MB (vs ~1GB for full Node images)

### Why Alpine?

- ✅ **Small**: 5MB base vs 100MB+ for Debian
- ✅ **Secure**: Minimal attack surface, fewer vulnerabilities
- ✅ **Fast**: Quick image pulls and container startup
- ✅ **Production-ready**: Industry standard for Node.js containers

---

## 📝 License

MIT

---

## 🎯 Quick Reference

### Deploy Command
```bash
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

### Update Command
```bash
./deploy-container-app.sh ssl-saas-demo-yourname westus
```

### View Logs
```bash
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow
```

### Delete Everything
```bash
az group delete --name ssl-saas-demo-yourname-rg --yes
```

---

**Time to deploy**: ~5 minutes  
**Time to configure SSL for SaaS**: ~5 minutes  
**Total**: ~10 minutes to full demo! ⚡

---

## 🚀 What's Different from App Service?

| Feature | App Service | Container Apps |
|---------|-------------|----------------|
| **Deployment** | `az webapp up` | Docker + `deploy-container-app.sh` |
| **Portability** | Azure-only | Run anywhere (local, cloud, multi-cloud) |
| **Scaling** | Basic autoscale | KEDA-based, scale to zero |
| **Cost** | Always running | Pay-per-use, can scale to zero |
| **Control** | Limited runtime control | Full container control |
| **URL Format** | `.azurewebsites.net` | `.azurecontainerapps.io` |
| **Architecture** | PaaS | Container-native (Kubernetes) |

### Benefits of Container Apps

- 🐳 **Portable**: Same container runs locally and in production
- 💰 **Cost-effective**: Scale to zero when not in use
- 🔄 **Flexible**: Easy to move between clouds
- 📦 **Modern**: Container-native, microservices-ready
- 🎯 **Precise**: Full control over runtime environment
## 🚀 What's Different from App Service?

| Feature | App Service | Container Apps |
|---------|-------------|----------------|
| **Deployment** | `az webapp up` | Docker + `deploy-container-app.sh` |
| **Portability** | Azure-only | Run anywhere (local, cloud, multi-cloud) |
| **Scaling** | Basic autoscale | KEDA-based, scale to zero |
| **Cost** | Always running | Pay-per-use, can scale to zero |
| **Control** | Limited runtime control | Full container control |
| **URL Format** | `.azurewebsites.net` | `.azurecontainerapps.io` |
| **Architecture** | PaaS | Container-native (Kubernetes) |

### Benefits of Container Apps

- 🐳 **Portable**: Same container runs locally and in production
- 💰 **Cost-effective**: Scale to zero when not in use
- 🔄 **Flexible**: Easy to move between clouds
- 📦 **Modern**: Container-native, microservices-ready
- 🎯 **Precise**: Full control over runtime environment
