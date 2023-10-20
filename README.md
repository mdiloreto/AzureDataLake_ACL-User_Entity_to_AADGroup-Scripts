
# Azure Data Lake Gen2 ACL Management Scripts

- `00-Backup_ACL.ps1`: This script backs up the current ACLs of a specified directory in Azure Data Lake Storage Gen2 to a CSV file.

- `01-Get-ACL-directory.ps1`: This script retrieves and prints the ACLs of a specified directory in Azure Data Lake Storage Gen2.

- `02-ReplaceRecursivo_ACLentitys-with-ADSecGroup-v2.ps1`: This script replaces the ACL entries of a specified directory in Azure Data Lake Storage Gen2 with a new ACL entry from an Azure AD security group.

- `03-RollbackRecursivo-Grant-ACL-from-csv.ps1`: This script adds ACL entries from a CSV file to a specified directory in Azure Data Lake Storage Gen2 and updates the ACLs recursively.

- `XX-Grant-recursive-acl-permissions.ps1`: This script grants recursive ACL permissions to a specified directory in Azure Data Lake Storage Gen2.

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

0. Install Az PowerShell Module: 

    https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-10.4.1

    For Windows: 

        1. Install AzureRM Module: 
        
            `Get-Module -Name AzureRM -ListAvailable`

        2. Set execution policy to unrestricted or remote signed: 

            `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

        3. Install Az Module: 

            `Install-Module -Name Az -Repository PSGallery -Force`

        4. Update if necessary: 

            Update-Module -Name Az -Force


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


# Assign ACL Permissions to Azure Data Lake Storage Gen2 Directory

This script assigns specified Access Control (ACL) permissions to a directory in Azure Data Lake Storage Gen2 for a range of users.

## Prerequisites

- Azure PowerShell module. Install by running `Install-Module -Name Az -Force`
- Azure Data Lake Storage Gen2 account and a container created.

## Usage

1. Set the following variables at the beginning of the script:

- `$Tenant`: Your Azure tenant ID.
- `$Sub`: Your Azure subscription ID.
- `$sa_name`: The name of your storage account.
- `$ContainerName`: The name of your container.
- `$dirname`: The path to your directory, ending with `/`.
- `$permissions`: The permissions you want to assign, in `rwx` format.

2. Run the script. It will prompt you to login to your Azure account.

## What the script does

1. Connects to your Azure account and sets the storage context.
2. Loops over 25 users (`user1@madsblog.onmicrosoft.com` to `user25@madsblog.onmicrosoft.com`) and assigns the specified ACL permissions to each user.
3. Updates the ACLs recursively for the specified directory.
4. Prints the updated ACLs of the directory.

## Important notes

- The script sets the specified permissions as the default scope for each user. If you do not want to set default permissions, comment out the `-DefaultScope` parameter in the `Set-AzDataLakeGen2ItemAclObject` cmdlets.
- Make sure the users you are assigning permissions to exist in your Azure AD tenant.


## Rollback Recursivo: 

This PowerShell script is designed to manage the Access Control Lists (ACLs) of a directory in Azure Data Lake Storage Gen2. It connects to your Azure account, retrieves the ACLs of a specified directory, removes specific ACL entries, then adds a new ACL entry from a CSV file. Finally, it updates the ACLs recursively for the specified directory and prints the final count of ACL entries.

$Tenant = ''                      # Azure Tenant ID
$Sub = ''                         # Azure Subscription ID
$SaName = ''                      # Storage Account Name
$ContainerName = ''                # Container Name
$DirName = ''                      # Directory Name, end with /
$ADSecGroupId = ''                 # Azure AD Security Group ID
$Pathcsv = ''                      # Path to CSV file containing ACL backup
$Permissions = 'rwx'               # Permissions in rwx notation
$PermissionsDetailed = 'Execute, Write, Read' # Permissions in detailed notation

1. Set your Azure Tenant ID, Subscription ID, Storage Account Name, Container Name, Directory Name, and the path to your ACL backup CSV file in the variables at the top of the script.

2. Run the script. It will do the following:
    - Connect to your Azure account.
    - Retrieve the current ACLs of the specified directory.
    - Remove all ACL entries with the specified permissions and which are of 'User' type.
    - Add ACL entries from the CSV file.
    - Update the ACLs recursively for the specified directory.
    - Print the final count of ACL entries.

The script will catch and print errors related to:
- Connecting to Azure or getting the filesystem.
- Getting the filesystem ACL.
- Removing an ACL entity.
- Removing ACL recursively.

Azure PowerShell module: Install it by running 'Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser' in PowerShell.

# Azure Data Lake Gen2 ACL Management Script

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

