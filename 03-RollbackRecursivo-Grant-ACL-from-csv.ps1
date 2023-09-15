$Tenant = ''
$Sub = ''
$SaName = ''
$ContainerName = ''
$DirName = '' #end with /
$ADSecGroupId = ''
#Atención Path
#Renombrar columna Permissions to "permissionsDetailed" y generar una nueva columna "permissions" con el equivalente de notación rwx
$Pathcsv = "C:\temp\gold-root2-sub01--20230914-091156-ACL_backup.csv" 
#>Atención Path<
$Permissions = "rwx"
$PermissionsDetailed = "Execute, Write, Read"

# >> START Connect to Azure account<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
try {
    Connect-AzAccount -TenantId $Tenant -SubscriptionId $Sub
    $Ctx = New-AzStorageContext -StorageAccountName $SaName -UseConnectedAccount
    #$Filesystem = Get-AzDataLakeGen2Item -Context $Ctx -FileSystem $ContainerName
}
catch {
    Write-Error "Error connecting to Azure or getting filesystem: $_"
    return
}
# >> End Connect to Azure account<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# >> START Borrar <<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

try {
    $FilesystemAcl = Get-AzDataLakeGen2Item -Context $Ctx -FileSystem $ContainerName -Path $DirName
    $FilesystemAclAcl = $FilesystemAcl.ACL
    $FilesystemAclAcl = $FilesystemAclAcl | Where-Object {$_.Permissions -eq $Permissions -and $_.EntityId -ne $null -and $_.AccessControlType -eq 'User'}


}
catch {
    Write-Error "Error getting filesystem ACL: $_"
    return
}
# >> START REMOVE ACL ENTRYS <<
# Remove ACL entities
if ($FilesystemAclAcl -eq $null) {

    Write-Host "No Entitys to delete"
}
else {
    Write-Host "ACL Entitys to delete:"
    $FilesystemAclAcl
    $i = 1
    foreach ($AclEntry in $FilesystemAclAcl) {
        try {
            if ($i -eq 1){
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $AclEntry.AccessControlType -EntityId $AclEntry.EntityId -Permission "---"
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $AclEntry.AccessControlType -EntityId $AclEntry.EntityId -Permission "---" -DefaultScope -InputObject $acl
            }
            else {
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $AclEntry.AccessControlType -EntityId $AclEntry.EntityId -Permission "---" -InputObject $acl
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $AclEntry.AccessControlType -EntityId $AclEntry.EntityId -Permission "---" -DefaultScope -InputObject $acl
            }
            $i++
        }
        catch {
            Write-Error "Error removing ACL entity: $_"
        }
    }
    try {
        Remove-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $ContainerName -Acl $acl -Path $DirName
    }
    catch {
        Write-Error "Error removing ACL recursively: $_"
        
    }
}    
# >> END REMOVE ACL ENTRYS <<

# >> START ADD AAD GROUP <<<

$ACLBackup = Import-Csv -path $Pathcsv
$ACLBackupCleaned = $ACLBackup | Where-Object {$_.EntityId -ne $null}
$i = 1

foreach ($aclentity in $ACLBackupCleaned) {

    if ($i -eq 1 ) {
            #fist without input
            if ($aclentity.DefaultScope -eq 'TRUE'){
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $aclentity.AccessControlType -Permission $aclentity.permissions -EntityId $aclentity.EntityId -DefaultScope 
            }
            else {
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $aclentity.AccessControlType -EntityId $aclentity.EntityId -Permission $aclentity.permissions 
            }
        }
        else {
            #with input $acl
            if ($aclentity.DefaultScope -eq 'TRUE'){
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $aclentity.AccessControlType -Permission $aclentity.permissions -EntityId $aclentity.EntityId -DefaultScope -InputObject $acl         }
            else {
                $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $aclentity.AccessControlType -EntityId $aclentity.EntityId -Permission $aclentity.permissions -InputObject $acl
            }  

        }
    $i++
    }

#Update ACL
Update-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $ContainerName -Acl $acl -Path $dirname

#>>START Get ACL

$filesystem_acl = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $dirname
$filesystem_acl.ACL | Format-Table  
$count = ($filesystem_acl.ACL | Where-Object { $_.DefaultScope -ne 'true' }).Count     
Write-Host "ACL entrys $count "

#>>END Get ACL