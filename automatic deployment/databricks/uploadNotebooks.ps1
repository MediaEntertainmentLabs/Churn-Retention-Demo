param([string]$apiUrl,
[string]$accessToken
)



Write-Output "upload notebooks"


Set-DatabricksEnvironment -ApiRootUrl $apiUrl -AccessToken $accessToken

Add-DatabricksWorkspaceDirectory -Path "/Demo/Churning"

$databricksNotebooks = Get-ChildItem "databricks/notebooks" *.ipynb


foreach($databricksNotebook in $databricksNotebooks){

    try{
        Import-DatabricksWorkspaceItem -Path "/Demo/Churning/$($databricksNotebook)" -LocalPath "databricks/notebooks/$($databricksNotebook)" -Format "JUPYTER"
    }
    catch [Exception]{
        write-host $_.exception;
    }
    
    Write-Output "databricksNotebook  $databricksNotebook uploaded in Databricks"
}
