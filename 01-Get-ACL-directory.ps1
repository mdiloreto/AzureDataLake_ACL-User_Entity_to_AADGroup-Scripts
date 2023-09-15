$Tenant = ''
$Sub =  '' 
$sa_name = ''
$ContainerName = ''
$dirname = '' #end with /
try {
# >> START Connect and context <<
Connect-AzAccount -TenantId $Tenant -SubscriptionId $Sub 
$ctx = New-AzStorageContext -StorageAccountName $sa_name -UseConnectedAccount
# >> END Connect and context <<
}
catch {
    Write-Host "Error connecting: $_" -ForegroundColor Red
}
#>>START Get ACL
try {
$filesystem_acl = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $dirname
Write-Host ">>>>ACL entrys for directory $dirname in container $containername <<<<" -ForegroundColor Green 
$filesystem_acl.ACL | Format-Table  
$count = ($filesystem_acl.ACL | Where-Object { $_.DefaultScope -ne 'true' }).Count     
Write-Host ">>>>ACL entrys $count" -ForegroundColor Gray -BackgroundColor Blue
}
catch {
    Write-Host "Error getting info: $_" -ForegroundColor Red 
}

#>>END Get ACL