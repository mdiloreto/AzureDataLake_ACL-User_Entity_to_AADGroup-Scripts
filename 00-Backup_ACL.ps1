$Tenant = ''
$Sub =  '' 
$sa_name = ''
$ContainerName = ''
$dirname = '' #end with /
$CleanedDirName = $DirName.Replace("/", "-")
#Group must be granted the same permissions as the users that will be part
$ADSecGroupId = ''
$Pathcsv = "C:\temp\$ContainerName-$CleanedDirName$(Get-Date -Format 'yyyyMMdd-HHmmss')-ACL_backup.csv"
#Its necessary to get both permissions format regular and detailed
$Permissions = "rwx"
$PermissionsDetailed = "Execute, Write, Read"


# Connect to Azure account
try {
    Connect-AzAccount -TenantId $Tenant -SubscriptionId $Sub
    $Ctx = New-AzStorageContext -StorageAccountName $sa_name -UseConnectedAccount
    #$Filesystem = Get-AzDataLakeGen2Item -Context $Ctx -FileSystem $ContainerName
}
catch {
    Write-Error "Error connecting to Azure or getting filesystem: $_"
    return
}

try {  
    Write-Host "Extracting ACL entitys with same permissions as specified, EntityId not equal to Null and AccessControlType is User" -ForegroundColor Blue
    $FilesystemAcl = Get-AzDataLakeGen2Item -Context $Ctx -FileSystem $ContainerName -Path $DirName
    $FilesystemAclAcl = $FilesystemAcl.ACL
    #Define entity ACL Scope
    $FilesystemAclAcl = $FilesystemAclAcl | Where-Object {$_.Permissions -eq $PermissionsDetailed -AND $_.EntityId -ne $null -and $_.AccessControlType -eq 'User'}
}
catch {
    Write-Error "Error getting filesystem ACL: $_"
    return
}

# >> START BACKUP <<
# Check for directory "C:\temp", if not exist create 
if (-not (Test-Path -Path "C:\temp")) {
    try {
        New-Item -ItemType Directory -Path "C:\temp"
    }
    catch {
        Write-Error "Error creating directory C:\temp: $_"
        return
    }
}

# Export old ACL to CSV
try {
    Write-Host "Backing Up to CSV to $pathcsv" -ForegroundColor Blue
    $FilesystemAclAcl | Export-Csv -Path $Pathcsv -NoTypeInformation
}
catch {
    Write-Error "Error exporting old ACL to CSV: $_"
    return
}
#>>START Get ACL
try {
$filesystemacl = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $dirname
Write-Host ">>>>ACL entrys for directory $dirname in container $containername <<<<" -ForegroundColor Green 
$filesystemacl.ACL | Format-Table  
$count = ($filesystemacl.ACL | Where-Object { $_.DefaultScope -ne 'true' }).Count     
Write-Host ">>>>ACL entrys $count" -ForegroundColor Gray -BackgroundColor Blue
}
catch {
    Write-Host "Error getting info: $_" -ForegroundColor Red 
}

#>>END Get ACL
