#!/bin/sh

readonly LIB_MUSL="musl"
readonly LIB_GCLIB="libc"
readonly LIB_DEFAULT="default"
readonly ALPINE_RELEASE_FILE="/etc/alpine-release"

readonly INSTALLER_DOWNLOAD_PATH="/tmp/installer.sh"
readonly INSTALLER_URL_SUFFIX="api/v1/deployment/installer/agent/unix/paas-sh/latest"

# Try using ldd command
check_ldd() {

    ldd_result=$(ldd /bin/echo)
    readonly ldd_result

    if echo "$ldd_result" | grep -qi "$LIB_MUSL"; then
        lib="$LIB_MUSL"
    elif echo "$ldd_result" | grep -qi "$LIB_GCLIB"; then
        lib="$LIB_DEFAULT"
    fi
}

check_alpine_release_file() {

    if [ -f "$ALPINE_RELEASE_FILE" ]; then
        lib="$LIB_MUSL"
    fi

}


run() {

    wget -O "$INSTALLER_DOWNLOAD_PATH" -q "$DT_ENDPOINT/$INSTALLER_URL_SUFFIX?Api-Token=$DT_API_TOKEN&flavor=$DT_FLAVOR&include=$DT_INCLUDE"
    sh "$INSTALLER_DOWNLOAD_PATH"

    # Inject variable into the proccess and run the actual application proccess
    LD_PRELOAD="/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so" $START_APP_CMD

}


main() {

    lib=""

    # First check using ldd utility
    check_ldd

    # If still empty check if Alpine release file exists
    if test -z "$lib"; then
        check_alpine_release_file
    fi

    # If lib is empty at the end, set it to "default"
    if test -z "$lib"; then
        lib="$LIB_DEFAULT"
    fi

    # Set dt_flavor based on detected libc
    DT_FLAVOR="$lib"

    run

}

main
