# Deployment Checklist - Azure Container Apps

## Pre-Deployment Checklist

### Azure Subscription Setup
- [ ] Logged into Azure (`az account show` works)
- [ ] Correct subscription selected
- [ ] **First-time only**: Register required providers
  ```bash
  az provider register --namespace Microsoft.ContainerRegistry
  az provider register --namespace Microsoft.App
  az provider register --namespace Microsoft.OperationalInsights
  ```
- [ ] Verify providers are registered (shows "Registered"):
  ```bash
  az provider show --namespace Microsoft.ContainerRegistry --query "registrationState"
  az provider show --namespace Microsoft.App --query "registrationState"
  ```

### Local Environment (if using local deployment)
- [ ] Docker installed and running (`docker ps` works)
- [ ] Azure CLI installed (`az --version` works)

### Code Verification
- [ ] Docker build succeeds locally (`docker build -t test .`)
- [ ] App runs locally (`docker-compose up` and test at http://localhost:8080)
- [ ] All endpoints work (/, /api/info)
- [ ] No errors in console logs

## Deployment Steps

### 1. Prepare
```bash
# Verify Docker is running
docker ps

# Verify Azure login
az login
az account show

# Choose unique app name
APP_NAME="ssl-saas-demo-yourname"
REGION="westus"
```

### 2. Deploy
```bash
# Run deployment script
./deploy-container-app.sh $APP_NAME $REGION
```

### 3. Monitor Deployment
Watch the script output for:
- [x] Resource group created
- [x] Container registry created
- [x] Docker image built
- [x] Image pushed to ACR
- [x] Container Apps environment created
- [x] Container app deployed
- [x] App URL displayed

**Expected time**: 3-5 minutes

### 4. Verify Deployment
```bash
# Get app URL
az containerapp show \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --query properties.configuration.ingress.fqdn -o tsv

# View logs
az containerapp logs show \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --follow
```

## Post-Deployment Verification

### Functional Tests
- [ ] App URL is accessible (https://...)
- [ ] Home page loads correctly
- [ ] API endpoint works (/api/info)
- [ ] Headers are displayed correctly
- [ ] Connection info is accurate
- [ ] Copy to clipboard works
- [ ] Refresh button works

### Infrastructure Tests
- [ ] Container is running (check Azure Portal)
- [ ] Logs are accessible
- [ ] Metrics are being collected
- [ ] Ingress is configured correctly
- [ ] HTTPS certificate is valid

## Optional: Custom Domain Setup

### Prerequisites
- [ ] Domain name owned and DNS access
- [ ] Container app deployed and running

### Steps
1. [ ] Get Container App FQDN
   ```bash
   az containerapp show \
     --name $APP_NAME \
     --resource-group ${APP_NAME}-rg \
     --query properties.configuration.ingress.fqdn -o tsv
   ```

2. [ ] Create DNS CNAME record
   ```
   CNAME: yourdomain.com → [container-app-fqdn]
   ```

3. [ ] Add custom domain in Azure Portal
   - Go to Container App → Custom domains
   - Add custom domain
   - Validate
   - Choose managed certificate
   - Wait for provisioning

4. [ ] Test custom domain
   - [ ] HTTPS works
   - [ ] Certificate is valid
   - [ ] App loads correctly

## Optional: Cloudflare SSL for SaaS

See `README.md` section "Cloudflare SSL for SaaS Setup" for detailed steps.

### Quick Checklist
- [ ] Custom domain added to Container App
- [ ] Cloudflare custom hostname created
- [ ] DNS CNAME configured
- [ ] SSL certificate issued
- [ ] Customer domain added to Container App
- [ ] Test through Cloudflare (CF-* headers visible)

## Monitoring Setup

### Azure Portal
- [ ] Navigate to Container App in Azure Portal
- [ ] Check "Metrics" tab
- [ ] Check "Log stream" tab
- [ ] Set up alerts (optional)

### CLI Monitoring
```bash
# Live logs
az containerapp logs show \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --follow

# Revision status
az containerapp revision list \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --output table

# App status
az containerapp show \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --query properties.runningStatus
```

## Scaling Configuration

### Current Settings
- Min replicas: 1
- Max replicas: 10
- CPU: 0.5 vCPU
- Memory: 1GB

### Adjust if Needed
```bash
# Scale to zero (save costs)
az containerapp update \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --min-replicas 0 \
  --max-replicas 10

# Increase resources
az containerapp update \
  --name $APP_NAME \
  --resource-group ${APP_NAME}-rg \
  --cpu 1.0 \
  --memory 2.0Gi
```

## Troubleshooting

### Ap**MissingSubscriptionRegistration error**: Register providers (see Pre-Deployment Checklist)
- [ ] p Won't Start
- [ ] Check logs: `az containerapp logs show --follow`
- [ ] Verify image was pushed: Check ACR in portal
- [ ] Check revision status: `az containerapp revision list`
- [ ] Verify environment variables are set

### Can't Access App
- [ ] Check ingress is enabled and external
- [ ] Verify HTTPS URL (not HTTP)
- [ ] Check firewall/network settings
- [ ] Verify app is running: Check portal

### Deployment Fails
- [ ] Check Azure quota in region
- [ ] Try different region
- [ ] Verify ACR name is unique
- [ ] Check Azure CLI is up to date

## Update Checklist

When updating the app:

1. [ ] Make code changes
2. [ ] Test locally with Docker
   ```bash
   docker-compose up --build
   ```
3. [ ] Redeploy
   ```bash
   ./deploy-container-app.sh $APP_NAME $REGION
   ```
4. [ ] Verify update
   - [ ] Check new revision is created
   - [ ] Test functionality
   - [ ] Check logs for errors

## Cleanup Checklist

When done with the demo:

```bash
# Delete everything
az group delete --name ${APP_NAME}-rg --yes --no-wait
```

This removes:
- [ ] Resource group
- [ ] Container registry
- [ ] Container Apps environment
- [ ] Container app
- [ ] All associated resources

## Success Criteria

Your deployment is successful when:
- ✅ App URL is accessible via HTTPS
- ✅ All endpoints return correct data
- ✅ Headers are displayed properly
- ✅ Logs are accessible
- ✅ No errors in container logs
- ✅ Metrics are being collected
- ✅ Custom domains work (if configured)
- ✅ Cloudflare integration works (if configured)

## Resources Created

Track what was created:
- Resource Group: `${APP_NAME}-rg`
- Container Registry: `${APP_NAME//"-"/""}acr`
- Container Apps Environment: `${APP_NAME}-env`
- Container App: `${APP_NAME}`

## Cost Tracking

Monitor costs in Azure Portal:
- Go to Subscriptions → Cost Management
- Filter by resource group: `${APP_NAME}-rg`
- Set up budget alerts (recommended)

Expected costs:
- Demo/Low traffic: $2-5/month
- Medium traffic: $10-20/month
- High traffic: Scales automatically

## Documentation Reference

- **Quick Start**: `QUICKSTART.md`
- **Full Guide**: `README.md`
- **Migration Details**: `MIGRATION.md`
- **Implementation**: `IMPLEMENTATION_SUMMARY.md`
- **This Checklist**: `DEPLOYMENT_CHECKLIST.md`

---

## Quick Command Reference

```bash
# Deploy
./deploy-container-app.sh ssl-saas-demo-yourname westus

# View logs
az containerapp logs show --name ssl-saas-demo-yourname --resource-group ssl-saas-demo-yourname-rg --follow

# Get URL
az containerapp show --name ssl-saas-demo-yourname --resource-group ssl-saas-demo-yourname-rg --query properties.configuration.ingress.fqdn -o tsv

# Delete
az group delete --name ssl-saas-demo-yourname-rg --yes
```

---

**Ready?** Start with the Pre-Deployment Checklist above! ✅
