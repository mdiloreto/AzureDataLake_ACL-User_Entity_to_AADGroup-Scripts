# Azure Data Lake Gen2 ACL Backup Script

This PowerShell script extracts Access Control List (ACL) entries with specific permissions from an Azure Data Lake Storage Gen2 filesystem and backs them up into a CSV file.

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

1. The script first connects to your Azure account using the provided tenant and subscription IDs.

2. Then, it extracts the ACL of the specified directory in the specified container, filtering the ACL entries to include only those with the specified detailed permissions, a non-null `EntityId`, and `AccessControlType` equal to 'User'.

3. The script then checks if the "C:\temp" directory exists on your local machine, creating it if necessary.

4. The filtered ACL entries are then exported to a CSV file in the "C:\temp" directory. The CSV file is named with the container and directory names and the current date and time.

5. Finally, the script retrieves and displays the ACL entries of the specified directory.

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
- Error getting the ACL entries of the specified directory.

## License

This project is licensed under the [MIT License](LICENSE).
