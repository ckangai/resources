#!/bin/bash

# --- Configuration ---
# IMPORTANT: Replace these placeholders with your actual project, zone, and VM name.
PROJECT_ID="{SUB_PROJECT_ID}"
ZONE="{SUB_ZONE}" # e.g., europe-west2-a
VM_NAME="{SUB_MYSQL_SERVER_VM}"

# --- Script Logic ---

echo "--- Disabling External IP for VM: ${VM_NAME} in ${ZONE} (Project: ${PROJECT_ID}) ---"

# 1. Get the current network interface name
# Most VMs have 'nic0' as their primary network interface.
# We'll try to retrieve it dynamically to be more robust.
NIC_NAME=$(gcloud compute instances describe "${VM_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --format="value(networkInterfaces[0].name)")

if [ -z "$NIC_NAME" ]; then
  echo "ERROR: Could not find network interface for VM '${VM_NAME}'. Exiting."
  exit 1
fi

echo "Found network interface: ${NIC_NAME}"

# 2. Disable the external IP address
echo "Attempting to unset external IP for ${VM_NAME}..."
gcloud compute instances delete-access-config "${VM_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --access-config-name="${NIC_NAME}" \
  --quiet # --quiet prevents interactive prompts

if [ $? -eq 0 ]; then
  echo "Successfully disabled external IP for VM '${VM_NAME}'."
  echo "The VM is now only accessible via its internal IP or IAP/VPN."
else
  echo "ERROR: Failed to disable external IP for VM '${VM_NAME}'."
  echo "Please check the VM name, project, zone, and your permissions."
fi

echo "--- Script finished ---"