# How to Use the Azure Connectivity Checker Script

This script is designed to test the connectivity to Azure endpoints from machine where ActiveGate is installed, both with and without proxy settings. 

Endpoints to test:
- https://management.azure.com
- https://login.microsoftonline.com
- https://management.core.windows.net

## Prerequisites
- **Bash Shell:** Ensure you have a bash-compatible shell environment to execute this script.
- **curl:** The script utilizes the `curl` command-line tool.

## Usage

1. **Download the Script:**
    - Download the script to your local machine. You can either copy the script content into a file or download it directly.

2. **Ensure Execution Permissions:**
    - Before executing the script, ensure it has execution permissions. You can grant execution permissions using the `chmod +x azure_connectivity_checker.sh` command.

3. **Execute the Script:**
    - Run the script from the terminal with appropriate parameters if needed. Run the script for the ActiveGate user, for which the ActiveGate was installed (`dtuserag` by default).

      Here's the general syntax:
      ```
      sudo -u dtuserag ./azure_connectivity_checker.sh [-p config_dir] [-c ssl_cert] [-s]
      ```
        - Options:
            - `-p`: Specifies the ActiveGate configuration directory. If not provided, the script tests connectivity directly without considering proxy settings.
            - `-c`: Specifies the SSL certificate file. This option is required if using a proxy.
            - `-s`: Run the script in silent mode. In this mode, output will only be logged to the file and not displayed on the console.

4. **View Results:**
    - Once executed, the script will test the connectivity to Azure endpoints.
    - The results will be displayed on the console and saved in a log file with a timestamp.

5. **Review Logs:**
    - To view detailed logs, check the generated log file in the `/var/lib/dynatrace/gateway/temp/azure_connectivity_logs/` folder.
    - The log file name includes a timestamp to differentiate between different executions.

6. **Interpret Results:**
    - The script will indicate whether the connectivity to Azure endpoints was successful or not for each tested endpoint.
    - It will also provide detailed curl commands and response outputs for each test in output file.

7. **Further Actions:**
    - Depending on the results, you may need to investigate further if any connectivity issues are identified.
    - If using a proxy, ensure that the SSL certificate provided (`-c` option) is valid.

8. **Cleanup:**
    - After reviewing the logs, you can remove them as needed to maintain a clean workspace.

## Notes
- If the ActiveGate configuration directory is not specified (**`p`** option), the script tests connectivity directly without considering proxy settings.
- If proxy settings are detected in the `custom.properties` file, the script automatically switches to testing connectivity via the specified proxy server and port.
- Ensure that you have the necessary permissions to access the ActiveGate configuration directory and SSL certificate file.

## Example Usage
To test connectivity without proxy settings:
```bash
sudo -u dtuserag ./azure_connectivity_checker.sh
```
To test connectivity via proxy:
```bash
sudo -u dtuserag ./azure_connectivity_checker.sh -p /path/to/config/directory -c /path/to/ssl/certificate.pem
```
