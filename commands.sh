az group create -l eastus2 -n "azure-cicd-rg"
az webapp up --sku F1 -l eastus2 -g "azure-cicd-rg" -n "azure-cicdapp"