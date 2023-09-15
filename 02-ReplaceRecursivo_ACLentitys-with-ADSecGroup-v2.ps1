$Tenant = '' 
$Sub =  '' 
$sa_name = ''
$ContainerName = ''
$dirname = '' #end with /
$CleanedDirName = $DirName.Replace("/", "-")
#Group must be granted the same permissions as the users that will be part
$ADSecGroupId = '640c1d8e-d11f-4c00-8c5a-665424c9bb75'
$Pathcsv = "C:\temp\$ContainerName-$CleanedDirName-$(Get-Date -Format 'yyyyMMdd-HHmmss')-ACL_backup.csv"
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

# >> END BACKUP <<

# >>>> Start Add Users to Group <<<
    #AD Group alternative 
    # # Get current members of the AD Group
$groupMembers = Get-AzADGroupMember -GroupObjectId $ADSecGroupId | ForEach-Object { $_.Id }

# Add users to AD Group
foreach ($AclEntry in $FilesystemAclAcl) {

        if ($groupMembers -contains $AclEntry.EntityId) {
            $userPrincipalName = (Get-AzADUser -ObjectId $AclEntry.EntityId).UserPrincipalName
            Write-Output "$userPrincipalName already a member"
        }
        else {
            if ($AclEntry.DefaultScope -ne 'true') {
                    try {
                        
                        Add-AzADGroupMember -TargetGroupObjectId $ADSecGroupId -MemberObjectId $AclEntry.EntityId
                        Write-Host "$userPrincipalName was added to the AD Security Group" -ForegroundColor Blue
                    }
                    catch {
                        Write-Error "Error adding user to AD group: $_"
                    }
                }
            }
    }

    # >> START REMOVE ACL ENTRYS <<
    # Remove ACL entities
$i = 1
foreach ($AclEntry in $FilesystemAclAcl) {
   
    try {
        if ($i -eq 1){
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $AclEntry.EntityId -Permission "---"
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $AclEntry.EntityId -Permission "---" -DefaultScope -InputObject $acl
        }
        else {
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $AclEntry.EntityId -Permission "---" -InputObject $acl
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $AclEntry.EntityId -Permission "---" -DefaultScope -InputObject $acl
        }
        $i++
    }
    catch {
        Write-Error "Error removing ACL entity: $_"
    }
}

try {
    Write-Host ">>>>ACL entitys deletion results<<<<" -ForegroundColor Red 
    Remove-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $ContainerName -Acl $acl -Path $DirName
}
catch {
    Write-Error "Error removing ACL recursively: $_"
    return
}

# >> END REMOVE ACL ENTRYS <<

# Grant permissions to AD Group
try {
    $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType group -EntityId $ADSecGroupId -Permission $Permissions -DefaultScope
    $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType group -EntityId $ADSecGroupId -Permission $Permissions -InputObject $acl
    Write-Host ">>>>ACL entitys group adding results<<<<" -ForegroundColor Green 
    Update-AzDataLakeGen2AclRecursive -Context $Ctx -FileSystem $ContainerName -Path $DirName -Acl $acl
}
catch {
    Write-Error "Error granting permissions to AD group: $_"
    return
}
#>>START Get ACL
$filesystem_acl = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $dirname
Write-Host ">>>>Updated ACL entrys<<<<" -ForegroundColor Green 
$filesystem_acl.ACL | Format-Table  
$count = ($filesystem_acl.ACL | Where-Object { $_.DefaultScope -ne 'true' }).Count     
Write-Host ">>>>ACL entrys $count" -ForegroundColor Gray -BackgroundColor Blue

#>>END Get ACL