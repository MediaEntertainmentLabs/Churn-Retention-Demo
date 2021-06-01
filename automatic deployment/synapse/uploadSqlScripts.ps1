param([string]$filesystem,
[string]$storage,
[string]$synapseWorkspaceName
)

$tokenValue = ((az account get-access-token --resource https://dev.azuresynapse.net) | ConvertFrom-Json).accessToken

function Wait-ForOperation {
    
    param(

    [parameter(Mandatory=$true)]
    [String]
    $WorkspaceName,

    [parameter(Mandatory=$false)]
    [String]
    $OperationId
    )

    if ([string]::IsNullOrWhiteSpace($OperationId)) {
        Write-Information "Cannot wait on an empty operation id."
        return
    }

    $uri = "https://${synapseWorkspaceName}.dev.azuresynapse.net/operationResults/$($OperationId)?api-version=2019-06-01-preview"
    $result = Invoke-RestMethod  -Uri $uri -Method GET -Headers @{ Authorization="Bearer $tokenValue" }

    while ($result.status -ne $null) {
        
        if ($result.status -eq "Failed") {
            throw $result.error
        }

        Write-Information "Waiting for operation to complete (status is $($result.status))..."
        Start-Sleep -Seconds 10
        $result = Invoke-RestMethod  -Uri $uri -Method GET -Headers @{ Authorization="Bearer $tokenValue" }
    }

    return $result
} 

$sqlScripts = Get-ChildItem "synapse/sqlscripts" *.json


foreach($sqlScript in $sqlScripts){
    
    $itemTemplate =  Get-Content -Path $sqlScript.FullName
    $item = $itemTemplate.Replace("#storage#", "$($filesystem)@$($storage)")
    
    $uri = "https://${synapseWorkspaceName}.dev.azuresynapse.net/sqlScripts/$($sqlScript.BaseName)?api-version=2019-06-01-preview"

    try{
        $response = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers  @{ Authorization="Bearer $tokenValue" } -ContentType "application/json"
    }
    catch [Exception]{
        Write-Error "Creation failure for $($_.name). Error: $($_.Exception.Message)"
        throw
    }
    
    
    Wait-ForOperation -WorkspaceName $synapseWorkspaceName -OperationId $response.operationId
    
    Write-Output "sqlscript  $sqlScript loaded in synapse workspace"
}






