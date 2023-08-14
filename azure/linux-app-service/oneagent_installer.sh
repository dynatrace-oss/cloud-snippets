#!/bin/sh

readonly ID_PREFIX='^ID='
readonly LIB_MUSL="musl"
readonly LIB_GCLIB="libc"
readonly LIB_DEFAULT="default"
readonly OS_RELEASE_FILE="/etc/os-release"
readonly ALPINE_RELEASE_FILE="/etc/alpine-release"
readonly DISTRIBUTION_WITH_MUSL="alpine"

readonly INSTALLER_LOCATION="/tmp/installer.sh"
readonly INSTALLER_URL_SUFFIX="api/v1/deployment/installer/agent/unix/paas-sh/latest"

# Try using ldd command
check_ldd() {

    ldd_result=$(ldd --version)
    readonly ldd_result

    if echo "$ldd_result" | grep -qi "$LIB_MUSL"; then
        lib="$LIB_$LIB_MUSL"
    elif echo "$ldd_result" | grep -qi "$LIB_GCLIB"; then
        lib="$LIB_DEFAULT"
    fi
}


check_release_file() {

    os_id=$(grep "$ID_PREFIX" "$OS_RELEASE_FILE" | cut -d= -f2 > /dev/null 2>&1)
    # -d specifies delimeter "=" and -f2 caputres second group after splitting

    if test "$os_id" = "$DISTRIBUTION_WITH_MUSL"; then
        lib="$LIB_MUSL"
    fi

}

check_alpine_release_file() {

    if [ -f "$ALPINE_RELEASE_FILE" ]; then
        lib="$LIB_MUSL"
    fi

}


run() {

    wget -O "$INSTALLER_LOCATION" -q "$DT_ENDPOINT/$INSTALLER_URL_SUFFIX?Api-Token=$DT_API_TOKEN&flavor=$DT_FLAVOR&include=$DT_INCLUDE"
    sh "$INSTALLER_LOCATION"

    # Inject variable into the proccess and run the actual application proccess
    LD_PRELOAD="/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so" $START_APP_CMD

}


main() {

    lib=""

    # First check using ldd utility
    check_ldd

    # If empty check /etc/os-release
    if test -z "$lib"; then
        check_release_file
    fi

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
