param(
    [parameter(Mandatory=$true)]
    [String]
    $resourceGroupName,
	[parameter(Mandatory=$true)]
    [String]
    $workspaceName,
	[parameter(Mandatory=$true)]
    [String]
    $dataricksworkspaceName,
	[parameter(Mandatory=$true)]
    [String]
    $functionName,
	[parameter(Mandatory=$true)]
    [String]
    $functionUrl,
    [parameter(Mandatory=$true)]
    [String]
    $LinkedStorageServiceName,
    [parameter(Mandatory=$true)]
    [String]
    $filesystem,
    [parameter(Mandatory=$true)]
    [String]
    $databricksHost
    )

Import-Module ".\synapse\synapse-automation-functions"


#setup subscription and tenant ID
$subscriptionId = (Get-AzContext).Subscription.Id
$global:logindomain = (Get-AzContext).Tenant.Id

#setup path containing definition of different artifacts
$templatesPath = ".\synapse\templates"
$datasetsPath = ".\synapse\datasets"
$pipelinesPath = ".\synapse\pipelines"


$global:synapseToken = ""
$global:synapseSQLToken = ""
$global:managementToken = ""

$global:tokenTimes = [ordered]@{
        Synapse = (Get-Date -Year 1)
        SynapseSQL = (Get-Date -Year 1)
        Management = (Get-Date -Year 1)
}



Write-output "Create Data databricks service $($dataricksworkspaceName)"

try {

    $result = Create-DatabricksLinkedService -TemplatesPath $templatesPath -WorkspaceName $workspaceName -Name "Databricks" -databricksHost $databricksHost
    Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId
}
catch {
    write-host $_.exception
}



Write-Output "create App Function LinkedService"

try {
    $result = Create-FunctionLinkedService -TemplatesPath $templatesPath -WorkspaceName $workspaceName -functionURL $functionUrl -Name "Function"
    Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId 
}
catch{
	write-host $_.exception;
}


Write-Output "Create Files Datasets"

    $datasets = @{
            Sink_Members_Dataset = $LinkedStorageServiceName
            Sink_Transactions_Dataset = $LinkedStorageServiceName
            Sink_Users_Logs_Dataset = $LinkedStorageServiceName    
            Source_Member_Dataset = $LinkedStorageServiceName
            Source_Transactions_Dataset = $LinkedStorageServiceName
            Source_Users_Logs_Dataset = $LinkedStorageServiceName
    }

    try {

        foreach ($dataset in $datasets.Keys) 
        {
                Write-output "Creating File Dataset $dataset"
                $result = Create-FileSystemDataset -DatasetsPath $datasetsPath -WorkspaceName $workspaceName -Name $dataset -LinkedServiceName $LinkedStorageServiceName -filesystem $filesystem
                Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId
        }
    }    
    catch{
        write-host $_.exception;
    }


Write-Output "create Serverless Pool LinkedService"
try {
    $result = Create-SQLPoolServerlessLinkedService -TemplatesPath $templatesPath -WorkspaceName $workspaceName -Name "Serverless Synapse"
    Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId  
}
catch {
    write-host $_.exception;
}

Write-output "Creating Serverless dataset"
    try {
        $result = Create-SqlPoolServerlessDataset -DatasetsPath $datasetsPath -WorkspaceName $workspaceName -Name "Serverless_Dataset" -LinkedServiceName "Serverless Synapse"
        Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId
    }
    catch {
        write-host $_.exception;
    }
    


Write-Output "Create pipelines"


$workloadPipelines = [ordered]@{
    "Churning Data Ingestion" = "Data_Ingestion"
    "Churning Model Creation" = "Churning_Model_Creation"
    "Churning Predictions" = "Churning_Predictions"
    "Churning Notifications" = "Churning_Notifications"
}

foreach ($pipeline in $workloadPipelines.Keys) 
{
    try
    {
        Write-output "Creating pipeline $pipeline"
        $result = Create-Pipeline -PipelinesPath $pipelinesPath -WorkspaceName $workspaceName -Name $pipeline -FileName $workloadPipelines[$pipeline]
        Wait-ForOperation -WorkspaceName $workspaceName -OperationId $result.operationId
    }
    catch
    {
        write-host $_.exception;
    }
}

