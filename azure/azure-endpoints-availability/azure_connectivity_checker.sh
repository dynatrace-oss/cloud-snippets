#!/bin/bash

# Azure endpoints to check
endpoints=("https://management.azure.com/" "https://login.microsoftonline.com/" "https://management.core.windows.net/")
isProxyUsed=false
config_dir=""
ssl_cert=""
silent_mode=false

# Create a folder named "azure_connectivity_logs" if it doesn't exist
log_folder="/var/lib/dynatrace/gateway/temp/azure_connectivity_logs" || { echo "Error creating log folder."; exit 1; }
mkdir -p "$log_folder" || { echo "Error creating log folder for user [$USER]"; exit 1; }

# Output file with timestamp will be store in the log folder
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="${log_folder}/azure_connectivity_check_${timestamp}.log"
touch "$output_file" || { echo "Error creating output file for user [$USER]"; exit 1; }

# Log to console and file
log_to_console_and_file() {
    echo -e "$1" | tee -a "$output_file"
}

# Log to file only
log_to_file() {
    echo -e "$1" >> "$output_file"
}

log_message() {
    local message="$1"
    if [ "$silent_mode" = true ]; then
        log_to_file "$message"
    else
        log_to_console_and_file "$message"
    fi
}

log_separator="-----------------------------------------------------------------------"
log_separator2="======================================================================="

log_to_console_and_file "$log_separator2"
log_to_console_and_file "Azure Connectivity Checker Script"
log_to_console_and_file "$log_separator2"
# Detect current working directory and user
log_to_console_and_file "Working directory: $PWD"
log_to_console_and_file "Current user: $USER"

# Read script parameters or set default values to directories
OPTSTRING=":p:c:s"

while getopts ${OPTSTRING} opt; do
    case ${opt} in
    p)
       config_dir=${OPTARG}
       ;;
    c)
        ssl_cert=${OPTARG}
        ;;
    s)
        silent_mode=true
        ;;
    :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
    ?)
        echo "Invalid option -${OPTARG}"
        exit 1
        ;;
    esac
done

direct_connect_command() {
  local endpoint="$1"
  curl_command="curl -v -I $endpoint --max-time 5"
  echo $curl_command
}

proxy_connect_command() {
  local endpoint="$1"
  local proxy_server="$2"
  local proxy_port="$3"
  local cert="$4"

  curl_command="curl -v -x https://$proxy_server:$proxy_port $endpoint:443 --proxy-cacert $cert"
  echo $curl_command
}

check_connectivity() {
    log_to_console_and_file "Checking the availability of Azure endpoints"
    log_to_console_and_file "$log_separator"

    for endpoint in "${endpoints[@]}"; do
        if [ "$isProxyUsed" = true ]; then
            # Check connection to Azure via proxy
            log_to_console_and_file "Checking connectivity to Azure endpoint [$endpoint:443] via [$proxy_server:$proxy_port]..."
            curl_str=`proxy_connect_command "$endpoint" "$proxy_server" "$proxy_port" "$ssl_cert"`
        else
            # Check direct connection to Azure endpoints
            log_to_console_and_file "Checking direct connectivity to Azure endpoint [$endpoint]..."
            curl_str=`direct_connect_command "$endpoint"`
        fi


        log_message "cURL command:\n$curl_str"
        log_message "Response:"

        curl_output=$($curl_str 2>&1)
        log_message "$curl_output"

        if [ $? -eq 0 ] && [[ "$curl_output" = *"left intact"* ]]; then
            log_to_console_and_file "Connection to $endpoint is SUCCESSFUL."
        else
            log_to_console_and_file "Connection to $endpoint is FAILED."
        fi
        log_to_console_and_file "$log_separator"
    done
}

if [ -z "$config_dir" ]; then
    log_to_console_and_file "ActiveGate configuration directory is not specified.
    - The direct connection to Azure endpoints will be tested without considering proxy settings.
    - To test the connection via proxy configured in custom.properties, please run the script with the parameter -p /path/to/config/directory and -c /path/to/certificate"
    # Check direct connection to Azure endpoints
    log_to_console_and_file "$log_separator2"
    check_connectivity
    echo "To check the complete log see $output_file"
    echo "$log_separator2"
    exit 0
fi

log_to_console_and_file "ActiveGate configuration directory: ${config_dir}"

# check read permission for activegate_config directory
if [ ! -r $config_dir ]; then
    echo "Cannot open directory $config_dir. Permission denied"
    exit 1
fi

if [ ! -d $config_dir ]; then
    echo "ActiveGate configuration directory does not exist: $config_dir"
    exit 1
fi

custom_properties_file="$config_dir/custom.properties"
if [ ! -f "$custom_properties_file" ]; then
    echo "custom.properties file is not found in $config_dir"
    exit 1
fi

read_properties() {
    local file="$1"
    local section="$2"

    while IFS='=' read -r key value; do
        if [[ $key == \[*] ]]; then
            current_section=$(echo "$key" | tr -d '[]')
        elif [[ "$current_section" == "$section" && "$key" && "$value" && ! "$key" =~ ^\s*# ]]; then
            echo "$key=$value"
        fi
    done < "$file"
}

# Read proxy settings from custom.properties
proxy_settings=$(read_properties "$custom_properties_file" "http.client")

if [ -z "$proxy_settings" ]; then
    log_to_console_and_file "$log_separator"
    log_to_console_and_file "No proxy settings found in $custom_properties_file"
else
    log_to_file "Detected proxy settings:\n\n[http.client]\n$proxy_settings\n"

    # Extract proxy server and port
    proxy_server=$((echo "$proxy_settings" | grep "proxy-server" | cut -d '=' -f 2) | xargs)
    proxy_port=$((echo "$proxy_settings" | grep "proxy-port" | cut -d '=' -f 2) | xargs)

    if [ -z "$proxy_server" ] || [ -z "$proxy_port" ]; then
        log_to_console_and_file "Proxy server or proxy port is not configured in $custom_properties_file. Server: $proxy_server, Port: $proxy_port"
    else
        isProxyUsed=true
        log_to_console_and_file "Detected proxy server and port in $custom_properties_file:\nServer: $proxy_server, Port: $proxy_port"

        if [ -z "$ssl_cert" ]; then
            log_to_console_and_file "The SSL certificate variable is empty. Please provide a valid certificate using option -c while running the script."
            exit 1
        fi
        if [ ! -f $ssl_cert ]; then
            log_to_console_and_file "SSL certificate $ssl_cert is not found."
            exit 1
        fi
        log_to_console_and_file "Proxy certificate: ${ssl_cert}"
    fi
fi

check_connectivity

echo "$log_separator2"
echo "To check the complete log see $output_file"