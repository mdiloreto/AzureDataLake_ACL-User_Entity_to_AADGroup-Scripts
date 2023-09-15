$Tenant = ''
$Sub =  ''
$sa_name = ''
$ContainerName = ''
$dirname = '' #end with /
$permissions = "rwx"

Connect-AzAccount -TenantId $Tenant -SubscriptionId $Sub
$ctx = New-AzStorageContext -StorageAccountName $sa_name -UseConnectedAccount
#$filesystem = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName

# Assign permissions to each user
for ($i = 1; $i -le 25; $i++) {
    
    $userUpn = "user$i@madsblog.onmicrosoft.com"
    $userId = (Get-AzADUser -UserPrincipalName $userUpn).Id
    
    if ($i -eq 1 ) {
        #fist without input
        $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -Permission $permissions -EntityId $userId -DefaultScope ##<<< default scope for each user comment if you dont want default permissions
        $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $userID -Permission $permissions -InputObject $acl
    }
    else {
        # All next with $acl input
        # Assign permissions
        $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -Permission $permissions -EntityId $userId -DefaultScope -InputObject $acl #<<< default scope for each user comment if you dont want default permissions
        $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $userID -Permission $permissions -InputObject $acl
    }

    Write-Host "Permissions assigned to $userUpn"
}
Update-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $ContainerName -Acl $acl -Path $dirname
Write-Host "Permissions assigned to all users"

#>>START Get ACL

$filesystem_acl = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $dirname
$filesystem_acl.ACL | Format-Table  
$count = ($filesystem_acl.ACL | Where-Object { $_.DefaultScope -ne 'true' }).Count     
Write-Host "ACL entrys $count "

#>>END Get ACL