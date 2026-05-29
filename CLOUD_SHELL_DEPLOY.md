# Deploy from Azure Cloud Shell

## ☁️ No Docker Required!

This guide shows you how to deploy directly from Azure Cloud Shell without needing Docker installed locally. Azure Cloud Shell uses **ACR Build Tasks** to build your container image in the cloud.

---

## 🚀 Deploy in 3 Steps

### Step 1: Open Azure Cloud Shell

Go to **https://shell.azure.com** (or click the shell icon in Azure Portal)

The Cloud Shell will automatically log you in to Azure.

### Step 2: Register Required Azure Providers (First Time Only)

**Important**: If this is your first time using Container Registry or Container Apps in your subscription, you need to register the resource providers:

```bash
# Register required providers (one-time setup per subscription)
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Wait for registration to complete (1-2 minutes)
# Check status - wait until all show "Registered"
az provider show --namespace Microsoft.ContainerRegistry --query "registrationState"
az provider show --namespace Microsoft.App --query "registrationState"
az provider show --namespace Microsoft.OperationalInsights --query "registrationState"
```

**Note**: If you've already deployed Container Apps or used Container Registry before, you can skip this step.

### Step 3: Clone and Deploy

```bash
# Clone the repository
git clone https://github.com/adz80/sample-azure-app-container.git
cd sample-azure-app-container

# Deploy with one command (change 'yourname' to something unique)
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus

# Done! Wait 3-5 minutes for deployment
```

**That's it!** No Docker installation needed.

---

## 🎯 What's Different?

### Regular Deployment (requires Docker)
```bash
./deploy-container-app.sh myapp westus
```
- ❌ Requires Docker Desktop installed
- ❌ Builds image locally
- ❌ Pushes from your machine

### Cloud Shell Deployment (no Docker needed)
```bash
./deploy-cloud-shell.sh myapp westus
```
- ✅ No Docker required
- ✅ Builds image in Azure (ACR Build Task)
- ✅ Everything happens in the cloud
- ✅ Works from any browser

---

## 📋 Script Parameters

```bash
./deploy-cloud-shell.sh <app-name> <region>
```

**Parameters:**
- `app-name`: Your unique app name (lowercase, alphanumeric, hyphens only)
- `region`: Azure region (default: westus)

**Example:**
```bash
./deploy-cloud-shell.sh ssl-saas-demo-mycompany eastus
```

**Available regions:**
- `westus`
- `eastus`
- `westeurope`
- `australiaeast`
- `southeastasia`

---

## 🔍 What the Script Does

1. ✅ Creates resource group
2. ✅ Creates Azure Container Registry (ACR)
3. ✅ **Builds Docker image in Azure** (using ACR Build Task)
4. ✅ Creates Container Apps environment
5. ✅ Deploys your container app
6. ✅ Configures ingress and scaling
7. ✅ Returns your app URL

**Key difference**: Step 3 uses `az acr build` which builds the image in Azure's cloud, not locally!

---

## 💡 How ACR Build Works

Instead of:
```bash
docker build -t myapp .
docker push myregistry.azurecr.io/myapp
```

We use:
```bash
az acr build --registry myregistry --image myapp .
```

This:
- Uploads your source code to Azure
- Builds the Docker image in Azure's cloud
- Stores it directly in your Container Registry
- No local Docker daemon needed!

---

## 🌐 Your App URL

After deployment, your app will be at:
```
https://ssl-saas-demo-yourname.[region].azurecontainerapps.io
```

The script will display the exact URL at the end.

---

## 📊 View Logs

```bash
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow
```

---

## 🔄 Update Your App

After making code changes:

```bash
# In Cloud Shell, pull latest changes
cd sample-azure-app-container
git pull

# Redeploy
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus
```

The script will rebuild the image in Azure and update your app.

---

## 🧹 Delete Everything

```bash
az group delete --name ssl-saas-demo-yourname-rg --yes
```

This removes all resources (resource group, ACR, container app, environment).

---

## 🆚 Comparison: Local vs Cloud Shell

| Feature | Local Deployment | Cloud Shell Deployment |
|---------|------------------|------------------------|
| **Docker Required** | ✅ Yes (Docker Desktop) | ❌ No |
| **Build Location** | Your computer | Azure cloud |
| **Internet Speed** | Uploads entire image | Uploads source code only |
| **Setup Time** | Install Docker (~10 min) | None (instant) |
| **Works From** | Your machine only | Any browser |
| **Script** | `deploy-container-app.sh` | `deploy-cloud-shell.sh` |

---

## ⚡ Quick Commands

### Deploy
```bash
./deploy-cloud-shell.sh ssl-saas-demo-yourname westus
```

### Get App URL
```bash
az containerapp show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --query properties.configuration.ingress.fqdn -o tsv
```

### View Logs
```bash
az containerapp logs show \
  --name ssl-saas-demo-yourname \
  --resource-group ssl-saas-demo-yourname-rg \
  --follow
```

### Delete
```bash
az group delete --name ssl-saas-demo-yourname-rg --yes
```

---

## 🎓MissingSubscriptionRegistration" Error
```
Error: The subscription is not registered to use namespace 'Microsoft.ContainerRegistry'
```

**Solution**: Register the required providers (first-time setup):
```bash
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Wait 1-2 minutes, then check status
az provider show --namespace Microsoft.ContainerRegistry --query "registrationState"
# Should show: "Registered"
```

Then retry your deployment.

### " When to Use Each Script

### Use `deploy-cloud-shell.sh` when:
- ✅ You don't have Docker installed
- ✅ You're working from a browser
- ✅ You're using Azure Cloud Shell
- ✅ You want the simplest deployment
- ✅ You're on a machine where you can't install Docker

### Use `deploy-container-app.sh` when:
- ✅ You have Docker installed locally
- ✅ You want to test the image locally first
- ✅ You're developing and iterating quickly
- ✅ You want to use `docker-compose` for local dev

---

## 🛠️ Troubleshooting

### "Command not found: ./deploy-cloud-shell.sh"
```bash
# Make sure you're in the right directory
cd sample-azure-app-container

# Make script executable
chmod +x deploy-cloud-shell.sh

# Run it
./deploy-cloud-shell.sh myapp westus
```

### "ACR name already exists"
```bash
# Use a more unique app name
./deploy-cloud-shell.sh ssl-saas-demo-mycompany-yourname westus
```

### "Quota exceeded"
```bash
# Try a different region
./deploy-cloud-shell.sh myapp westeurope
```

### Build fails
```bash
# Check the Dockerfile exists
ls -la Dockerfile

# Check you're in the right directory
pwd
# Should show: .../sample-azure-app-container
```

---

## 📚 Next Steps

1. **Deploy**: Run the cloud shell script
2. **Test**: Visit your app URL
3. **Configure**: Add custom domains (see README.md)
4. **Cloudflare**: Set up SSL for SaaS (see README.md)

---

## 🎉 Advantages of Cloud Shell Deployment

1. **No Setup**: Works immediately, no installations
2. **Any Device**: Deploy from any computer or tablet
3. **Fast Upload**: Only uploads source code, not Docker images
4. **Secure**: Credentials managed by Azure
5. **Consistent**: Same environment every time
6. **Free**: Cloud Shell is free with your Azure subscription

---

## 📞 Support

For issues:
- Check this guide's troubleshooting section
- View deployment script output for errors
- Check Azure Portal for resource status
- See `README.md` for detailed documentation

---

**Time to deploy**: ~5 minutes  
**Prerequisites**: Azure subscription only  
**Docker required**: No ❌  
**Works from**: Any browser ✅
