#!/bin/bash

# Azure Container Apps Deployment Script - Cloud Shell Optimized
# This script is designed to run in Azure Cloud Shell (https://shell.azure.com)
# It uses Azure Container Registry build tasks instead of local Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="${1:-ssl-saas-demo}"
LOCATION="${2:-westus}"
RESOURCE_GROUP="${APP_NAME}-rg"
ACR_NAME="${APP_NAME//-/}acr"
CONTAINER_APP_ENV="${APP_NAME}-env"
IMAGE_NAME="ssl-saas-demo"
IMAGE_TAG="latest"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Azure Container Apps Deployment${NC}"
echo -e "${GREEN}(Cloud Shell Optimized)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Configuration:"
echo "  App Name:          ${APP_NAME}"
echo "  Location:          ${LOCATION}"
echo "  Resource Group:    ${RESOURCE_GROUP}"
echo "  ACR Name:          ${ACR_NAME}"
echo "  Environment:       ${CONTAINER_APP_ENV}"
echo ""

# Check if Azure CLI is available (should always be in Cloud Shell)
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    exit 1
fi

# Check if logged in to Azure (should be automatic in Cloud Shell)
echo -e "${YELLOW}Checking Azure login...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Azure${NC}"
    echo "Run: az login"
    exit 1
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${GREEN}✓ Logged in to Azure${NC}"
echo "  Subscription: ${SUBSCRIPTION}"
echo ""

# Step 1: Create Resource Group
echo -e "${YELLOW}Step 1: Creating resource group...${NC}"
if az group show --name "${RESOURCE_GROUP}" &> /dev/null; then
    echo -e "${GREEN}✓ Resource group already exists${NC}"
else
    az group create \
        --name "${RESOURCE_GROUP}" \
        --location "${LOCATION}" \
        --output none
    echo -e "${GREEN}✓ Resource group created${NC}"
fi
echo ""

# Step 2: Create Azure Container Registry
echo -e "${YELLOW}Step 2: Creating Azure Container Registry...${NC}"
if az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP}" &> /dev/null; then
    echo -e "${GREEN}✓ ACR already exists${NC}"
else
    az acr create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${ACR_NAME}" \
        --sku Basic \
        --admin-enabled true \
        --output none
    echo -e "${GREEN}✓ ACR created${NC}"
fi

ACR_LOGIN_SERVER=$(az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP}" --query loginServer -o tsv)
echo "  ACR Login Server: ${ACR_LOGIN_SERVER}"
echo ""

# Step 3: Build Docker Image using ACR Build Task (no local Docker needed!)
echo -e "${YELLOW}Step 3: Building Docker image in Azure (ACR Build Task)...${NC}"
echo "  This uses Azure's cloud build service - no local Docker required!"
az acr build \
    --registry "${ACR_NAME}" \
    --image "${IMAGE_NAME}:${IMAGE_TAG}" \
    --file Dockerfile \
    .
echo -e "${GREEN}✓ Docker image built and pushed to ACR${NC}"
echo ""

# Step 4: Create Container Apps Environment
echo -e "${YELLOW}Step 4: Creating Container Apps environment...${NC}"
if az containerapp env show --name "${CONTAINER_APP_ENV}" --resource-group "${RESOURCE_GROUP}" &> /dev/null; then
    echo -e "${GREEN}✓ Container Apps environment already exists${NC}"
else
    az containerapp env create \
        --name "${CONTAINER_APP_ENV}" \
        --resource-group "${RESOURCE_GROUP}" \
        --location "${LOCATION}" \
        --output none
    echo -e "${GREEN}✓ Container Apps environment created${NC}"
fi
echo ""

# Step 5: Get ACR credentials
echo -e "${YELLOW}Step 5: Retrieving ACR credentials...${NC}"
ACR_USERNAME=$(az acr credential show --name "${ACR_NAME}" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "${ACR_NAME}" --query passwords[0].value -o tsv)
echo -e "${GREEN}✓ ACR credentials retrieved${NC}"
echo ""

# Step 6: Deploy Container App
echo -e "${YELLOW}Step 6: Deploying container app...${NC}"
if az containerapp show --name "${APP_NAME}" --resource-group "${RESOURCE_GROUP}" &> /dev/null; then
    echo "Updating existing container app..."
    az containerapp update \
        --name "${APP_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --image "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}" \
        --output none
    echo -e "${GREEN}✓ Container app updated${NC}"
else
    echo "Creating new container app..."
    az containerapp create \
        --name "${APP_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --environment "${CONTAINER_APP_ENV}" \
        --image "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}" \
        --registry-server "${ACR_LOGIN_SERVER}" \
        --registry-username "${ACR_USERNAME}" \
        --registry-password "${ACR_PASSWORD}" \
        --target-port 8080 \
        --ingress external \
        --min-replicas 1 \
        --max-replicas 10 \
        --cpu 0.5 \
        --memory 1.0Gi \
        --env-vars NODE_ENV=production PORT=8080 \
        --output none
    echo -e "${GREEN}✓ Container app created${NC}"
fi
echo ""

# Step 7: Get the app URL
echo -e "${YELLOW}Step 7: Retrieving app URL...${NC}"
APP_URL=$(az containerapp show \
    --name "${APP_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query properties.configuration.ingress.fqdn -o tsv)

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your app is running at:"
echo -e "${GREEN}https://${APP_URL}${NC}"
echo ""
echo "Next steps:"
echo "  1. Visit your app: https://${APP_URL}"
echo "  2. Test the API: https://${APP_URL}/api/info"
echo "  3. Add custom domains in Azure Portal → Container Apps → Custom domains"
echo "  4. Configure Cloudflare SSL for SaaS with custom hostnames"
echo ""
echo "Useful commands:"
echo "  View logs:    az containerapp logs show --name ${APP_NAME} --resource-group ${RESOURCE_GROUP} --follow"
echo "  Restart app:  az containerapp revision restart --name ${APP_NAME} --resource-group ${RESOURCE_GROUP}"
echo "  Delete app:   az group delete --name ${RESOURCE_GROUP} --yes"
echo ""
echo "Resources created:"
echo "  Resource Group:  ${RESOURCE_GROUP}"
echo "  ACR:            ${ACR_NAME}"
echo "  Container App:  ${APP_NAME}"
echo "  Environment:    ${CONTAINER_APP_ENV}"
echo ""
