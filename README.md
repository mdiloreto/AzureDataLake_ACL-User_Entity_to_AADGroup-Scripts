
# Azure Data Lake Gen2 ACL Management Scripts

00-Backup_ACL.ps1: This script backs up the current ACLs of a specified directory in Azure Data Lake Storage Gen2 to a CSV file.

01-Get-ACL-directory.ps1: This script retrieves and prints the ACLs of a specified directory in Azure Data Lake Storage Gen2.

02-ReplaceRecursivo_ACLentitys-with-ADSecGroup-v2.ps1: This script replaces the ACL entries of a specified directory in Azure Data Lake Storage Gen2 with a new ACL entry from an Azure AD security group.

03-RollbackRecursivo-Grant-ACL-from-csv.ps1: This script adds ACL entries from a CSV file to a specified directory in Azure Data Lake Storage Gen2 and updates the ACLs recursively.

XX-Grant-recursive-acl-permissions.ps1: This script grants recursive ACL permissions to a specified directory in Azure Data Lake Storage Gen2.

# AD Entitys recursive replacement with AAD Group 

This PowerShell script manages Access Control List (ACL) entries of a specified directory in an Azure Data Lake Storage Gen2 container. It backs up the old ACL entries to a CSV file, adds users to an Active Directory (AD) security group, removes old ACL entries, and grants permissions to the AD security group.

## Parameters

- `$Tenant`: Azure tenant ID.
- `$Sub`: Azure subscription ID.
- `$sa_name`: Storage account name.
- `$ContainerName`: Name of the Data Lake Storage Gen2 container.
- `$DirName`: Directory path ending with a forward slash ("/").
- `$ADSecGroupId`: Active Directory security group ID.
- `$Permissions`: Short form of permissions ("rwx").
- `$PermissionsDetailed`: Detailed form of permissions ("Execute, Write, Read").

## How it works

1. The script connects to your Azure account using the provided tenant and subscription IDs.

2. It extracts the ACL of the specified directory in the specified container, filtering the ACL entries to include only those with the specified detailed permissions, a non-null `EntityId`, and `AccessControlType` equal to 'User'.

3. The filtered ACL entries are then exported to a CSV file in the "C:\temp" directory. The CSV file is named with the container and directory names and the current date and time.

4. The script retrieves the current members of the specified AD security group. Then, for each filtered ACL entry, if the user is not already a member of the AD security group, they are added to the group.

5. The script removes the old ACL entries from the specified directory. Then, it grants the specified permissions to the AD security group.

6. Finally, the script retrieves and displays the updated ACL entries of the specified directory.

## Usage

1. Fill in the parameter values at the top of the script.

2. Run the script in PowerShell.

## Note

The Active Directory security group specified in `$ADSecGroupId` must have the same permissions as the users that will be part of the group.

## Error handling

The script will return an error message and stop executing if any of the following occurs:

- Error connecting to Azure or getting the filesystem.
- Error getting the filesystem ACL.
- Error creating the "C:\temp" directory.
- Error exporting the old ACL to CSV.
- Error adding a user to the AD security group.
- Error removing an ACL entry.
- Error removing the ACL recursively.
- Error granting permissions to the AD security group.


