# 4. Private VM Error Simulation
# This script runs on {SUB_PRIVATE_TEST_SERVER_LINUX_NAME}. It simulates failed attempts to access the internet (due to no #### external IP), process crashes, and memory pressure.

## File: simulate_private_vm_errors.sh
# 4
#!/bin/bash
# simulate_private_vm_errors.sh
# Runs on {SUB_PRIVATE_TEST_SERVER_LINUX_NAME} (Internal IP: {SUB_PRIVATE_TEST_SERVER_LINUX_IP})
# Simulates errors on a private VM.

PROJECT_ID="{SUB_PROJECT_ID}"
PRIVATE_LINUX_VM_NAME="{SUB_PRIVATE_TEST_SERVER_LINUX_NAME}"
# Intentionally attempt to access external internet (should fail as no external IP)
GOOGLE_DNS="8.8.8.8"

echo "Starting private VM error simulation on ${PRIVATE_LINUX_VM_NAME}..."

# --- Error Simulation ---

echo "Simulating attempts to ping external IP (expected to fail - no external IP on private VPC VM)..."
(while true; do
  ping -c 1 "${GOOGLE_DNS}" &> /dev/null
  if [ $? -ne 0 ]; then
    logger -t "${PRIVATE_LINUX_VM_NAME}-network" "OK: Ping to external IP ${GOOGLE_DNS} failed as expected (no external access) at $(date)."
  else
    logger -t "${PRIVATE_LINUX_VM_NAME}-network" "CRITICAL: Ping to external IP ${GOOGLE_DNS} SUCCEEDED unexpectedly at $(date)."
  fi
  sleep 5
done) &
echo "Private VM external network access error simulation started (PID $!)"

echo "Simulating a critical process crash message..."
(while true; do
  logger -t "${PRIVATE_LINUX_VM_NAME}-proc" "CRITICAL: Core process 'DataAggregator' dumped core due to unhandled exception at $(date). Service is now degraded."
  sleep 45
done) &
echo "Private VM critical process error simulation started (PID $!)"

echo "Simulating high memory usage surges..."
(while true; do
  logger -t "${PRIVATE_LINUX_VM_NAME}-mem" "WARNING: Entering high memory usage phase at $(date)."
  # Allocate 200MB memory using Python, wait for 30s then release
  python3 -c "import time; import os; mem = os.urandom(200 * 1024 * 1024); time.sleep(30);" &> /dev/null
  logger -t "${PRIVATE_LINUX_VM_NAME}-mem" "INFO: High memory usage phase completed, memory released at $(date)."
  sleep 90 # Wait before next surge
done) &
echo "Private VM memory pressure simulation started (PID $!)"

if bq --project_id="${PROJECT_ID}" mk --schema=product_id:integer,product_name:string,supplier_id:integer,category_id:integer,quantity_per_unit:string,unit_price:float,units_in_stock:integer,units_on_order:integer,reorder_level:integer,discontinued:boolean --table "$1:demos.products" 2>&1 | logger -t "bq-table-creation"; then
  echo "Successfully created BigQuery table $1:demos.products." | logger -t "bq-table-creation"
else
  echo "ERROR: Failed to create BigQuery table $1:demos.products. Check logs for details." | logger -t "bq-table-creation"
fi

bq --project_id="${PROJECT_ID}" query \
   --use_legacy_sql=false \
   --format=prettyjson \
   "SELECT * FROM demos.products"

echo "Private VM simulation scripts are running in the background. Check logs for activity in Cloud Logging."
