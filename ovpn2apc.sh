#!/bin/bash

# Extract a specific section from the file
function extract_section() {
    local filepath=$1
    local start_marker=$2
    local end_marker=$3
    awk "/$start_marker/,/$end_marker/" "$filepath"
}

# Convert OVPN to APC format
function ovpn_to_apc() {
    local src=$1
    local dst=$2

    # Extract important parts
    local ca_cert=""
    ca_cert=$(extract_section "${src}" "$CERT_START" "$CERT_END")
    local proto=""
    proto=$(grep "proto" "${src}" | awk '{print $2}')
    local remote_address=""
    remote_address=$(grep "remote" "${src}" | awk '{print $2}')
    local remote_port=""
    remote_port=$(grep "remote" "${src}" | awk '{print $3}')
    local cipher=""
    cipher=$(grep "cipher" "${src}" | awk '{print $2}')
    local auth=""
    auth=$(grep "auth" "${src}" | awk '{print $2}')

    # Setup dummy values for missing fields
    local key=""
    local server_dn="C=NA, ST=NA, L=NA, O=NA, OU=NA, CN=Appliance_Certificate_LABWJ30kV5ihdMM, emailAddress=na@example.com"
    local username="SRV_E297F42126B2DD3F1105FBD0A0754C89"
    local password="SRV_E297F42126B2DD3F1105FBD0A0754C89_0000_211245320"
    local compression="0"  # Explicitly disabling compression

    # Create the APC file content
    cat << EOF > "${dst}"

{
  "protocol": "${proto}",
  "key": "${key}",
  "server_port": "${remote_port}",
  "authentication_algorithm": "${auth}",
  "server_address": ["${remote_address}"],
  "server_dn": "${server_dn}",
  "encryption_algorithm": "${cipher}",
  "compression": "${compression}",
  "ca_cert": "${ca_cert}",
  "certificate": "",
  "username": "${username}",
  "password": "${password}"
}
EOF
}

# grab values passed to script
function main() {
    local src=$1
    local dst=$2

    if [[ -z $src || -z $dst ]]; then
        echo "Usage: $0 <src.ovpn> <dst.apc>"
        exit 1
  fi

    ovpn_to_apc "${src}" "${dst}"
}

main "$@"
