# 2. MySQL Client Traffic Simulation
# This script runs on {MYSQL_CLIENT_VM}. It continuously queries the MySQL server, and attempts error conditions like # wrong credentials or wrong ports.

# File: simulate_mysql_client_traffic.sh
# 2
#!/bin/bash
# simulate_mysql_client_traffic.sh
# Runs on {SUB_MYSQL_CLIENT_VM} (Internal IP: {SUB_MYSQL_CLIENT_VM_IP})
# Originates from public-vpc, accesses private-vpc via peering using internal IPs.

# VM and IP details
MYSQL_SERVER_VM_IP="{SUB_MYSQL_SERVER_VM_IP}" # <--- IP address (not name)
MYSQL_CLIENT_VM_NAME="{SUB_MYSQL_CLIENT_VM}"

echo "Starting MySQL client traffic simulation on ${MYSQL_CLIENT_VM_NAME}..."

# --- Load Simulation ---

echo "Simulating frequent successful MySQL queries (allowed by private-allow-mysql)..."
(while true; do
  mysql -h "${MYSQL_SERVER_VM_IP}" -u testuser -ptestpassword -D testdb -e "SELECT 1;" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "$(date): MySQL query to ${MYSQL_SERVER_VM_IP} successful."
  else
    logger -t "${MYSQL_CLIENT_VM_NAME}" "ERROR: MySQL query to ${MYSQL_SERVER_VM_IP} failed unexpectedly at $(date)."
  fi
  sleep 0.5 # High frequency
done) &
echo "MySQL client query load started (PID $!)"

# --- Error Simulation ---

echo "Simulating MySQL connection with wrong password (expected to fail - application level error)..."
(while true; do
  mysql -h "${MYSQL_SERVER_VM_IP}" -u testuser -pwrongpassword -D testdb -e "SELECT 1;" &> /dev/null
  if [ $? -ne 0 ]; then
    logger -t "${MYSQL_CLIENT_VM_NAME}" "OK: MySQL connection with wrong password failed as expected at $(date)."
  else
    logger -t "${MYSQL_CLIENT_VM_NAME}" "CRITICAL: MySQL connection with wrong password SUCCEEDED unexpectedly at $(date)."
  fi
  sleep 10
done) &
echo "MySQL client invalid password error simulation started (PID $!)"

echo "Simulating MySQL connection to non-standard/blocked port 3307 (expected to fail - no firewall rule for 3307)..."
(while true; do
  # Assuming 3307 is not open for MySQL traffic
  mysql -h "${MYSQL_SERVER_VM_IP}" --port=3307 -u testuser -ptestpassword -D testdb -e "SELECT 1;" &> /dev/null
  if [ $? -ne 0 ]; then
    logger -t "${MYSQL_CLIENT_VM_NAME}" "OK: MySQL connection to non-standard port 3307 failed as expected at $(date)."
  else
    logger -t "${MYSQL_CLIENT_VM_NAME}" "CRITICAL: MySQL connection to non-standard port 3307 SUCCEEDED unexpectedly at $(date)."
  fi
