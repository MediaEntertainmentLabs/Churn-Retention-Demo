# Managing Retention and Churn with Azure and Databricks
End to End solution built with Azure Databricks and other Azure services (Synapse, Azure Function, Logic App, Power BI) to predict churns and so retain customers.
<br>The KKbox datasets used are from Kaggle challenge: https://www.kaggle.com/c/kkbox-churn-prediction-challenge/data. 
<br>KKbox is a music streaming service.
<br> Machine Learning models are from the Databricks blog: https://databricks.com/blog/2020/08/24/profit-driven-retention-management-with-machine-learning.html

# Overview

![image](https://user-images.githubusercontent.com/49620357/120338689-78bc9180-c2c2-11eb-9c02-8e2010d44067.png)

<br>Data have been manually copied to Azure Data Lake from Kaggle.
<br>In a real scenario, data will be sourced from transactional systems.

![image](https://user-images.githubusercontent.com/49620357/120373222-15dcf180-c2e6-11eb-9467-83859f73b099.png)

# Results

Use a Power BI dashboard to get meaningfull insights and prevent customers to churn
<br>![image](https://user-images.githubusercontent.com/49620357/120370860-19bb4480-c2e3-11eb-927f-324c99a7f3bc.png)




# Prerequisites

* Azure Subscription
* Terraform (for deployment)
* Powershell (for deployment)
* Databricks Powershell (for the Databricks deployment part) : https://github.com/gbrueckl/Databricks.API.PowerShell
  * Install-Module -Name DatabricksPS

# Deployment
Run the following commands from the automatic deployment directory:
* terraform init
* terraform plan
* terraform apply -auto-approve

Deployment will create all the resources part of the architecture.
<br>![image](https://user-images.githubusercontent.com/49620357/120354216-42860e80-c2d0-11eb-9723-1b376ad7813f.png)
In addition of creating resources, deployment will also:
* Azure Databricks
  * Upload notebook in the Databricks Workspace
* Azure Synapse Analytics
  * Upload Sql scripts in Azure Synapse Analytics
  * Create the Linked Services
  * Create the Datasets
  * Create the Pipelines
* Azure Data Lake Storage
  * Create the directories where raw data and predictions will be saved

From the resource-group tf file in the resource-group directory, you will find out what is the name of the resource group created.
Per default, resource group name will start with *e2e-churn-demo-*

# Step 1 Databricks setup

* Create a cluster : https://docs.microsoft.com/en-us/azure/databricks/clusters/create
* Mount the storage (created during the deployment) in Databricks
  * You can use the notebook "Churn 00_Mount Storage"  (uploaded automatically during the deployment) as a template
  * The example relies on Azure Key Vault and Databricks Key Vault https://docs.microsoft.com/en-us/azure/databricks/security/secrets/secret-scopes
  * https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/adls-gen2/azure-datalake-gen2-sp-access
* Upload KKbox Dataset from Kaggle (https://www.kaggle.com/c/kkbox-churn-prediction-challenge/data) then run the notebook called "Load Data" (uploaded automatically during the deployment)

# Step 2 Role assignment
https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=current
 * Assign the storage blob data contributor role to e2e-churn-demo-3v8nqm (Synapse Workspace) for the storage e2echurndemostor3v8nqm
 * Assign the storage blob data contributor role to e2e-churn-demo-workspace-3v8nqm (Databricks Workspace) for the storage e2echurndemostor3v8nqm
   * As for Databricks, You will have to create a Service Principal. It will be used to access the data lake.
   * https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/adls-gen2/azure-datalake-gen2-sp-access

# Step 3 Run the sql scripts in the Synapse Serverless Pool

When deploying the solution, SQL scripts are uploaded automatically.
<br>![image](https://user-images.githubusercontent.com/49620357/120351541-f934bf80-c2cd-11eb-992c-c57da656986c.png)

Please run at least these 2 scripts in this order on the serverless pool:
<br>https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/author-sql-script#run-your-sql-script
* **Create Database Demo** 
* **Create Master Key**
  * choose a Master Key Encryption password and run the script using the Database Demo
* **Run any SQL script left**

<br> Make sure to select the serverless Pool
![image](https://user-images.githubusercontent.com/49620357/120357236-3780ad80-c2d3-11eb-9786-32cf433585ad.png)


# Step 4 Check Linked Services in Azure Synapse

When deploying the solution, Linked Services are created automatically.

Please verify the connection for the following Linked Services:
* Serverless Synapse
<br>![image](https://user-images.githubusercontent.com/49620357/120358780-e2de3200-c2d4-11eb-8f1a-bb14c26e2521.png)
  * Enter the password (check the synapse.tf file) and test the connection
* Databricks
<br>![image](https://user-images.githubusercontent.com/49620357/120366737-02c62380-c2de-11eb-9172-1df42abf8d97.png)
  * Get a Databricks Token : https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/authentication#--generate-a-personal-access-token)
  * Create a cluster in Databricks that will be used to run the Databricks Notebooks : https://docs.microsoft.com/en-us/azure/databricks/clusters/create
  * Enter these information and test the connection

# Step 5 Azure Function (optional)
An Azure function is automatically created once deployment is complete.
<br>You will have to implement the code. In this case, bind the function to a queue.
<br> In this architecture we are sending a message to a queue (predictionChurning) to trigger a logic app workflow. The logic app will send an email with a Power BI dashboard attached containing information about potential customer churns.
<br>![image](https://user-images.githubusercontent.com/49620357/120370197-4753be00-c2e2-11eb-85e1-d9719aad8d9c.png)
<br>![image](https://user-images.githubusercontent.com/49620357/120370393-897cff80-c2e2-11eb-99d2-be537d5262b4.png)
<br>![image](https://user-images.githubusercontent.com/49620357/120368892-9862b280-c2e0-11eb-9ba4-68835aaa7732.png)
https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook

# Step 6 Azure Logic App (optional)

You can implement easily different type of logic with logic app.
<br>In this architecture, we use it to automatically refresh the Power BI report then send an email with the dashboard attached.
<br>https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-overview

<br>![image](https://user-images.githubusercontent.com/49620357/120371732-386e0b00-c2e4-11eb-8e91-97ddeebc6261.png)

# Step 7 Run the different pipelines
* You can create the model directly in Databricks or use the pipeline Churning Model Creation in Azure Synapse
  * You will have to mount the storage and have the KKbox dataset in your datalake.
* You can run the prediction notebook in Databricks or use the pipeline Churning predictions in Azure Synapse
* You can run the notification pipeline in Azure Synapse to trigger the Logic app workflow and receive the Power BI report automatically in an email.
  * You can also visualize directly the report in Azure Synapse.
  * https://docs.microsoft.com/en-us/azure/synapse-analytics/quickstart-power-bi 


# Resources

* https://github.com/microsoft/MCW-Azure-Synapse-Analytics-and-AI
* https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
* https://databricks.com/blog/2020/08/24/profit-driven-retention-management-with-machine-learning.html
* https://docs.microsoft.com/en-us/azure/machine-learning/overview-what-is-azure-ml





