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
