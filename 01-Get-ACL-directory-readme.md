# Azure Data Lake Gen2 ACL Retrieval Script

This PowerShell script retrieves and displays the Access Control List (ACL) entries of a specified directory in an Azure Data Lake Storage Gen2 container.

## Parameters

- `$Tenant`: Azure tenant ID.
- `$Sub`: Azure subscription ID.
- `$sa_name`: Storage account name.
- `$ContainerName`: Name of the Data Lake Storage Gen2 container.
- `$DirName`: Directory path ending with a forward slash ("/").

## How it works

1. The script first connects to your Azure account using the provided tenant and subscription IDs.

2. Then, it retrieves the ACL of the specified directory in the specified container.

3. The ACL entries of the specified directory are then displayed in a table, and the count of entries with `DefaultScope` not equal to 'true' is displayed.

## Usage

1. Fill in the parameter values at the top of the script.

2. Run the script in PowerShell.

## Error handling

The script will display an error message if any of the following occurs:

- Error connecting to Azure.
- Error getting the ACL entries of the specified directory.

## License

This project is licensed under the [MIT License](LICENSE).
