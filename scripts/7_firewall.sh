#!/bin/bash

# --- Configuration ---
# IMPORTANT: Replace these placeholders with your actual project ID and network name.
PROJECT_ID="{SUB_PROJECT_ID}"
NETWORK_NAME="private-vpc" # The name of your VPC network
FIREWALL_RULE_NAME="private-vpc-allow-ssh" # The name of the firewall rule to modify
NEW_SOURCE_RANGES="10.1.1.0/24" # The new source IP range

# --- Script Logic ---

echo "--- Modifying Firewall Rule: ${FIREWALL_RULE_NAME} ---"
echo "Project: ${PROJECT_ID}"
echo "Network: ${NETWORK_NAME}"
echo "New Source Ranges: ${NEW_SOURCE_RANGES}"

# Check if the firewall rule exists (optional, but good practice)
echo "Checking if firewall rule '${FIREWALL_RULE_NAME}' exists..."
gcloud compute firewall-rules describe "${FIREWALL_RULE_NAME}" \
  --project="${PROJECT_ID}" \
  --format="value(name)" &>/dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: Firewall rule '${FIREWALL_RULE_NAME}' not found in project '${PROJECT_ID}'. Exiting."
  exit 1
fi

echo "Firewall rule found. Proceeding with modification."

# Modify the firewall rule
gcloud compute firewall-rules update "${FIREWALL_RULE_NAME}" \
  --project="${PROJECT_ID}" \
  --network="${NETWORK_NAME}" \
  --source-ranges="${NEW_SOURCE_RANGES}" \
  --quiet # --quiet prevents interactive prompts

if [ $? -eq 0 ]; then
  echo "Successfully updated firewall rule '${FIREWALL_RULE_NAME}'."
  echo "Verify the changes by running: gcloud compute firewall-rules describe ${FIREWALL_RULE_NAME} --project=${PROJECT_ID}"
else
  echo "ERROR: Failed to update firewall rule '${FIREWALL_RULE_NAME}'."
  echo "Please check your project ID, network name, firewall rule name, and permissions."
fi

echo "--- Script finished ---"