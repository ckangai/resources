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
# (e.g., messages tagged with {SUB_PRIVATE_TEST_SERVER_LINUX_NAME}, {SUB_MYSQL_CLIENT_VM}, 
# {SUB_MYSQL_SERVER_VM}, etc.) to see the simulated load and errors.
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

PUBLIC_LINUX_VM="{SUB_PUBLIC_TEST_SERVER_LINUX_NAME}" # Used for gcloud command, gcloud handles name resolution here
PRIVATE_LINUX_VM="{SUB_PRIVATE_TEST_SERVER_LINUX_NAME}" # Used for gcloud command, gcloud handles name resolution here
MYSQL_CLIENT_VM="{SUB_MYSQL_CLIENT_VM}" # Used for gcloud command, gcloud handles name resolution here
MYSQL_SERVER_VM="{SUB_MYSQL_SERVER_VM}" # Used for gcloud command, gcloud handles name resolution here

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
echo "--- Step 1: Initializing MySQL Server and Client ---"
# Run the setup script first
echo "Deploying 1.sh on ${MYSQL_CLIENT_VM}..."
gcloud compute scp 1.sh "${MYSQL_CLIENT_VM}:~/1.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${MYSQL_CLIENT_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/1.sh && nohup ~/1.sh &> ~/mysql_setup.log &"
echo "MySQL setup script launched (check ~/mysql_setup.log and Cloud Logging)...."

# ****************************************************************
echo ""
echo "--- Step 2: Deploying & Executing Simulation Scripts on VMs ---"

# Deploy and run public VM traffic simulation
echo "Deploying 2.sh on ${PUBLIC_LINUX_VM}..."
gcloud compute scp 2.sh "${PUBLIC_LINUX_VM}:~/2.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${PUBLIC_LINUX_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/2.sh && nohup ~/2.sh &> ~/public_vm_traffic.log &"
echo "Public VM simulation script launched (check ~/public_vm_traffic.log and Cloud Logging)."

# ****************************************************************
# Deploy and run MySQL client traffic simulation
echo "Deploying 3.sh on ${MYSQL_CLIENT_VM}..."
gcloud compute scp 3.sh "${MYSQL_CLIENT_VM}:~/3.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${MYSQL_CLIENT_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/3.sh && nohup ~/3.sh &> ~/mysql_client_traffic.log &"
echo "MySQL client simulation script launched (check ~/mysql_client_traffic.log and Cloud Logging)."

# ****************************************************************
# Deploy and run MySQL server error simulation
echo "Deploying 4.sh on ${MYSQL_SERVER_VM}..."
gcloud compute scp 4.sh "${MYSQL_SERVER_VM}:~/4.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${MYSQL_SERVER_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/4.sh && nohup ~/4.sh &> ~/mysql_server_errors.log &"
echo "MySQL server error simulation script launched (check ~/mysql_server_errors.log and Cloud Logging)."

# ****************************************************************
# Deploy and run private VM error simulation
echo "Deploying 5.sh on ${PRIVATE_LINUX_VM}..."
gcloud compute scp 5.sh "${PRIVATE_LINUX_VM}:~/5.sh" --zone "${ZONE}" --project "${PROJECT_ID}"
gcloud compute ssh "${PRIVATE_LINUX_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" \
  --command="chmod +x ~/5.sh && nohup ~/5.sh &> ~/private_vm_errors.log &"
echo "Private VM error simulation script launched (check ~/private_vm_errors.log and Cloud Logging)."

# ****************************************************************
echo ""
echo "--- All simulation scripts are now running in the background on their respective VMs. ---"
echo "You can check the logs via Google Cloud Logging in the GCP Console."
echo "Press Ctrl+C to stop this orchestration script (background processes on VMs will continue)."
echo "To terminate the simulations on the VMs, SSH into each VM and kill the respective processes (e.g., 'pkill -f 2.sh')."

# Keep the orchestrator running to provide visual confirmation.
tail -f /dev/null
