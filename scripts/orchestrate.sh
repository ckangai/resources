# Phase 3: Orchestration Script (Local Execution)
# This script automates the deployment and execution of the simulation scripts on your VMs.

# File: orchestrate_all_simulations.sh alias 6.sh
# ******************************************************
# How to use:
# Save the scripts: Create the five files listed above:
# setup_gcp_environment.sh or 1.sh, simulate_public_vm_traffic.sh or 2.sh, 
# simulate_mysql_client_traffic.sh or 3.sh, simulate_mysql_server_errors.sh or 4.sh, 
# simulate_private_vm_errors.sh or 5.sh, orchestrate_all_simulations.sh or 6.sh
# in the same directory on your local machine or Cloud Shell.

# Run the orchestration script
# chmod +x *.sh ./6.sh

# Observe Logs: Go to the Google Cloud Console, navigate to Logging > Logs Explorer.
# Filter by resource.type="gce_instance" to see all VM logs.
# Look for specific log messages from the scripts 
# (e.g., messages tagged with private-test-server-linux-9808a183, mysql-client-9808a183, 
# mysql-server-9808a183, etc.) to see the simulated load and errors.
# You'll see successful pings, SSH connections, MySQL queries, as well as the injected "ERROR" 
# and "CRITICAL" messages from logger for the simulated faults. You will also see expected 
# connection failures due to firewall rules or lack of external IPs.


# 5
#!/bin/bash
# 6.sh
# Main script to set up environment and deploy simulation scripts to VMs.
# Run this locally from your machine.

PROJECT_ID="{SUB_PROJECT_ID}"
ZONE="{SUB_ZONE}"

PUBLIC_LINUX_VM="public-test-server-linux-9808a183" # Used for gcloud command, gcloud handles name resolution here
PRIVATE_LINUX_VM="private-test-server-linux-9808a183" # Used for gcloud command, gcloud handles name resolution here
MYSQL_CLIENT_VM="mysql-client-9808a183" # Used for gcloud command, gcloud handles name resolution here
MYSQL_SERVER_VM="mysql-server-9808a183" # Used for gcloud command, gcloud handles name resolution here

# --- BigQuery Errors Simulation ---
if bq --project_id="${PROJECT_ID}" mk --schema=product_id:integer,product_name:string,supplier_id:integer,category_id:integer,quantity_per_unit:string,unit_price:float,units_in_stock:integer,units_on_order:integer,reorder_level:integer,discontinued:boolean --table "$1:demos.products" 2>&1 | logger -t "bq-table-creation"; then
  echo "Successfully created BigQuery table ${PROJECT_ID}:demos.products." | logger -t "bq-table-creation"
else
  echo "ERROR: Failed to create BigQuery table ${PROJECT_ID}:demos.products. Check logs for details." | logger -t "bq-table-creation"
fi

bq --project_id="${PROJECT_ID}" query \
   --use_legacy_sql=false \
   --format=prettyjson \
   "SELECT * FROM demos.products"

bq --project_id="${PROJECT_ID}" query \
   --use_legacy_sql=false \
   --format=prettyjson \
   "SELECT 1/0"


bq mk --dataset ${PROJECT_ID}:demos

bq --project_id ${PROJECT_ID} load --source_format=CSV \
--autodetect \
demos.customers \
gs://${PROJECT_ID}/customers.csv

# Functions to check if a VM is running
is_vm_running() {
  gcloud compute instances describe "$1" --zone "${ZONE}" --project "${PROJECT_ID}" --format="value(status)" 2>/dev/null | grep -q "RUNNING"
}

# Wait for all VMs to be running before starting
echo "--- Waiting for all VMs to be in RUNNING state... ---"
VMS=("$PUBLIC_LINUX_VM" "$PRIVATE_LINUX_VM" "$MYSQL_CLIENT_VM" "$MYSQL_SERVER_VM")
for vm in "${VMS[@]}"; do
  echo "Checking ${vm}..."
  while ! is_vm_running "${vm}"; do
    echo "  ${vm} not yet running. Waiting 10 seconds..."
    sleep 10
  done
  echo "  ${vm} is RUNNING."
done
echo "All VMs are running. Proceeding with setup and simulations."


# ****************************************************************
echo ""
echo "--- Step 2: Deploying & Executing Simulation Scripts on VMs ---"

# Deploy and run public VM traffic simulation
echo "Deploying 2.sh on ${PUBLIC_LINUX_VM}..."
gcloud compute scp 2.sh "${PUBLIC_LINUX_VM}:~/2.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${PUBLIC_LINUX_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/2.sh && nohup ~/2.sh &> ~/public_vm_traffic.log &"
echo "Public VM simulation script launched (check ~/public_vm_traffic.log and Cloud Logging)."

