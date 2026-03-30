#!/bin/bash

echo "Fetching instances (JSON mode)..."

declare -a ALL_INSTANCES
declare -a ALL_LABELS

# Single API call + JSON parsing
while read -r id name image; do
    if [[ "$image" == *OPNsense* ]]; then
        ALL_INSTANCES+=("$id")
        ALL_LABELS+=("[OPNsense] $name ($id)")
    elif [[ "$image" == *Windows* ]]; then
        ALL_INSTANCES+=("$id")
        ALL_LABELS+=("[Windows]  $name ($id)")
    fi
done < <(
    openstack server list -f json 2>/dev/null | \
    jq -r '.[] | "\(.ID) \(.Name) \(.Image)"'
)

# Check if empty
if [ ${#ALL_INSTANCES[@]} -eq 0 ]; then
    echo "Error: No matching instances found."
    exit 1
fi

echo ""
echo "Found the following instances:"
echo "----------------------------------------------"
for i in "${!ALL_LABELS[@]}"; do
    echo "  $((i+1))) ${ALL_LABELS[$i]}"
done
echo "----------------------------------------------"

while true; do
    read -p "Select an instance [1-${#ALL_INSTANCES[@]}]: " SELECTION
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && \
       [ "$SELECTION" -ge 1 ] && \
       [ "$SELECTION" -le "${#ALL_INSTANCES[@]}" ]; then
        break
    else
        echo "Invalid selection."
    fi
done

INSTANCE_ID="${ALL_INSTANCES[$((SELECTION-1))]}"
echo ""
echo "Selected: ${ALL_LABELS[$((SELECTION-1))]}"

read -p "Enter the path to your SSH private key [~/.ssh/id_rsa]: " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}

echo "Retrieving password..."
nova get-password "$INSTANCE_ID" "$KEY_PATH"