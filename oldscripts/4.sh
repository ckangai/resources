# 3. MySQL Server Error Simulation
# This script runs on {SUB_MYSQL_SERVER_VM}. It simulates service outages, disk full conditions, and generic database errors.

# File: simulate_mysql_server_errors.sh
#3 
#!/bin/bash
# simulate_mysql_server_errors.sh
# Runs on {SUB_MYSQL_SERVER_VM} (Internal IP: {SUB_MYSQL_SERVER_VM_IP})
# Simulates internal errors on the private MySQL server.

MYSQL_SERVER_VM_NAME="{SUB_MYSQL_SERVER_VM}"

echo "Starting MySQL server error simulation on ${MYSQL_SERVER_VM_NAME}..."

# --- Error Simulation ---

echo "Simulating MySQL service stopping and restarting every 75 seconds..."
(while true; do
  logger -t "${MYSQL_SERVER_VM_NAME}-mysql" "WARNING: Simulating MySQL service shutdown at $(date)."
  sudo systemctl stop mysql &> /dev/null
  sleep 15 # MySQL service down for 15 seconds, causing connection failures for clients
  logger -t "${MYSQL_SERVER_VM_NAME}-mysql" "INFO: Restarting MySQL service at $(date)."
  sudo systemctl start mysql &> /dev/null
  sleep 60 # Run for 60 seconds before next stop
done) &
echo "MySQL service stop/start simulation started (PID $!)"

echo "Simulating temporary disk full condition every 2 minutes..."
(while true; do
  logger -t "${MYSQL_SERVER_VM_NAME}-disk" "ERROR: Simulating disk nearly full incident by creating a large dummy file at $(date)."
  # Create a 500MB file to consume space
  dd if=/dev/zero of=/tmp/large_dummy_file bs=1M count=500 &> /dev/null
  sync # Ensure disk writes are flushed
  sleep 30 # Disk full for 30 seconds
  rm -f /tmp/large_dummy_file
  logger -t "${MYSQL_SERVER_VM_NAME}-disk" "INFO: Disk space restored at $(date)."
  sleep 90 # Wait 1.5 minutes before next incident
done) &
echo "MySQL server disk full simulation started (PID $!)"

echo "Simulating a generic database corruption/table error message..."
(while true; do
  logger -t "${MYSQL_SERVER_VM_NAME}-dbapp" "CRITICAL: Database system detected an internal consistency check failure on 'users' table at $(date). Manual intervention required."
  sleep 90
done) &
echo "MySQL server database error simulation started (PID $!)"

echo "MySQL server simulation scripts are running in the background. Check logs for activity in Cloud Logging."