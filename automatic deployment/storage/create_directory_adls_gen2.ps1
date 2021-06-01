param([string]$storageAccountName,
[string] $filesystemName
)


$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount


New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "sources/members" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "sources/transactions" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "sources/users_logs"  -Directory

New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "members" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "silver" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "transactions" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "user_logs"  -Directory

New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "synapse/tables/members" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "synapse/tables/predictions" -Directory
New-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path "synapse/tables/user_logs"  -Directory




