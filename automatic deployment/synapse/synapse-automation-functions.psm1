function Create-DatabricksLinkedService {

    param(
     [parameter(Mandatory=$true)]
     [String]
     $TemplatesPath,
 
     [parameter(Mandatory=$true)]
     [String]
     $WorkspaceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $Name,
 
     [parameter(Mandatory=$true)]
     [String]
     $databricksHost
     )
 
     $itemTemplate = Get-Content -Path "$($TemplatesPath)/databricks_linked_service.json"
     $item = $itemTemplate.Replace("#DatabricksWorkspaceHost#", $databricksHost)
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/linkedServices/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
 
     return $result
 }
 
 function Create-SQLPoolServerlessLinkedService {
     
     param(
     [parameter(Mandatory=$true)]
     [String]
     $TemplatesPath,
 
     [parameter(Mandatory=$true)]
     [String]
     $WorkspaceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $Name
     )
 
     $itemTemplate = Get-Content -Path "$($TemplatesPath)/Serverless_Synapse.json"
     $item = $itemTemplate.Replace("#WORKSPACE#", $WorkspaceName)
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/linkedServices/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
 
     return $result
 }
 
 
 
 function Create-FunctionLinkedService {
     param(
         [parameter(Mandatory=$true)]
         [String]
         $TemplatesPath,
 
         [parameter(Mandatory=$true)]
         [String]
         $WorkspaceName,
     
         [parameter(Mandatory=$true)]
         [String]
         $functionURL,
     
         [parameter(Mandatory=$true)]
         [String]
         $Name
     )
 
     $itemTemplate = Get-Content -Path "$($TemplatesPath)/function.json"
     $item = $itemTemplate.Replace("#URL_FUNCTION#", $functionURL)
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/linkedServices/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
     
     return $result
 
 }
 
 function Ensure-ValidTokens {
 
     for ($i = 0; $i -lt $tokenTimes.Count; $i++) {
         Ensure-ValidToken $($tokenTimes.Keys)[$i]
     }
 }
 
 function Ensure-ValidToken {
     param(
         [parameter(Mandatory=$true)]
         [String]
         $TokenName
     )
 
     $refTime = Get-Date
 
     if (($refTime - $tokenTimes[$TokenName]).TotalMinutes -gt 30) {
         Write-Information "Refreshing $($TokenName) token."
         Refresh-Token $TokenName
         $tokenTimes[$TokenName] = $refTime
     }
 }
 
 function Refresh-Token {
     param(
     [parameter(Mandatory=$true)]
     [String]
     $TokenType
     )
 
     switch($TokenType) {
         "Synapse" {
             $tokenValue = ((az account get-access-token --resource https://dev.azuresynapse.net) | ConvertFrom-Json).accessToken
             $global:synapseToken = $tokenValue; 
             break;
         }
         "SynapseSQL" {
             $tokenValue = ((az account get-access-token --resource https://sql.azuresynapse.net) | ConvertFrom-Json).accessToken
             $global:synapseSQLToken = $tokenValue; 
             break;
         }
         "Management" {
             $tokenValue = ((az account get-access-token --resource https://management.azure.com) | ConvertFrom-Json).accessToken
             $global:managementToken = $tokenValue; 
             break;
         }
         default {throw "The token type $($TokenType) is not supported.";}
     }
     
 }
 
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
 
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/operationResults/$($OperationId)?api-version=2019-06-01-preview"
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method GET -Headers @{ Authorization="Bearer $synapseToken" }
 
     while ($result.status -ne $null) {
         
         if ($result.status -eq "Failed") {
             throw $result.error
         }
 
         Write-Information "Waiting for operation to complete (status is $($result.status))..."
         Start-Sleep -Seconds 10
         Ensure-ValidTokens
         $result = Invoke-RestMethod  -Uri $uri -Method GET -Headers @{ Authorization="Bearer $synapseToken" }
     }
 
     return $result
 }
 
 function Create-Pipeline {
     
     param(
     [parameter(Mandatory=$true)]
     [String]
     $PipelinesPath,
 
     [parameter(Mandatory=$true)]
     [String]
     $WorkspaceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $Name,
 
     [parameter(Mandatory=$true)]
     [String]
     $FileName,
 
     [parameter(Mandatory=$false)]
     [Hashtable]
     $Parameters = $null
     )
 
     $item = Get-Content -Path "$($PipelinesPath)/$($FileName).json"
     
     if ($Parameters -ne $null) {
         foreach ($key in $Parameters.Keys) {
             $item = $item.Replace("#$($key)#", $Parameters[$key])
         }
     }
 
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/pipelines/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
     
     return $result
 }
 
 function Create-FileSystemDataset {
     
     param(
     [parameter(Mandatory=$true)]
     [String]
     $DatasetsPath,
 
     [parameter(Mandatory=$true)]
     [String]
     $WorkspaceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $Name,
 
     [parameter(Mandatory=$true)]
     [String]
     $LinkedServiceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $filesystemName
 
 
     )
 
     $itemTemplate = Get-Content -Path "$($DatasetsPath)/$($Name).json"
     $item = $itemTemplate.Replace("#LinkedServiceName#", $LinkedServiceName).Replace("#filesystem#",$filesystemName)
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/datasets/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $item -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
     
     return $result
 }
 
 
 function Create-SqlPoolServerlessDataset {
     
     param(
     [parameter(Mandatory=$true)]
     [String]
     $DatasetsPath,
 
     [parameter(Mandatory=$true)]
     [String]
     $WorkspaceName,
 
     [parameter(Mandatory=$true)]
     [String]
     $Name,
 
     [parameter(Mandatory=$true)]
     [String]
     $LinkedServiceName
     )
 
     $itemTemplate = Get-Content -Path "$($DatasetsPath)/$($Name).json"
     $uri = "https://$($WorkspaceName).dev.azuresynapse.net/datasets/$($Name)?api-version=2019-06-01-preview"
 
     Ensure-ValidTokens
     $result = Invoke-RestMethod  -Uri $uri -Method PUT -Body $itemTemplate -Headers @{ Authorization="Bearer $synapseToken" } -ContentType "application/json"
     
     return $result
 }
 
 Export-ModuleMember -Function Create-DatabricksLinkedService
 Export-ModuleMember -Function Create-Pipeline
 Export-ModuleMember -Function Create-FileSystemDataset
 Export-ModuleMember -Function Create-SqlPoolServerlessDataset
 Export-ModuleMember -Function Create-FunctionLinkedService
 Export-ModuleMember -Function Create-SQLPoolServerlessLinkedService
 Export-ModuleMember -Function Wait-ForOperation