# Phase 2: Simulation Scripts (to be run on VMs)
# These scripts define the load and error scenarios. They use logger to write specific error messages that will appear in # # Cloud Logging, making them easy to identify.

# 1. Public VM Traffic Simulation
# This script runs on {SUB_PRIVATE_TEST_SERVER_LINUX_NAME}. It simulates legitimate SSH connections to private VMs, generates CPU # load, and logs application errors.

# File: simulate_public_vm_traffic.sh

# Phase 2: Simulation Scripts (to be run on VMs)
#!/bin/bash
# simulate_public_vm_traffic.sh
# Runs on {SUB_PRIVATE_TEST_SERVER_LINUX_NAME} (Internal IP: {SUB_PRIVATE_TEST_SERVER_LINUX_IP})
# Originates from public-vpc, accesses private-vpc via peering using internal IPs.

# VM and IP details (from Terraform output)
PRIVATE_LINUX_VM_IP="{SUB_PRIVATE_TEST_SERVER_LINUX_IP}" # <--- IP address (not name)
MYSQL_SERVER_VM_IP="{SUB_MYSQL_SERVER_VM_IP}"  # <--- IP address (not name)
PUBLIC_VM_NAME="{SUB_PRIVATE_TEST_SERVER_LINUX_NAME}"

echo "Starting public VM traffic simulation on ${PUBLIC_VM_NAME}..."

# --- Load Simulation ---

echo "Simulating continuous pings to private VMs (allowed from 10.1.1.0/24 to 10.2.2.0/24 by private-allow-ping)..."
(while true; do
  ping -c 1 "${PRIVATE_LINUX_VM_IP}" &> /dev/null
  echo "$(date): Pinged ${PRIVATE_LINUX_VM_IP}"
  ping -c 1 "${MYSQL_SERVER_VM_IP}" &> /dev/null
  echo "$(date): Pinged ${MYSQL_SERVER_VM_IP}"
  sleep 1
done) &
echo "Public VM Ping load started (PID $!)"

echo "Simulating CPU load for 60 seconds (every 90s interval)..."
(while true; do
  # Using 'timeout' to limit execution duration
  timeout 60s bash -c 'while true; do echo "CPU load ongoing..."; done' &> /dev/null
  echo "$(date): CPU load cycle complete."
  sleep 30 # Wait 30 seconds after 60s of load
done) &
echo "Public VM CPU load started (PID $!)"

echo "Simulating repeated SSH attempts to private VMs (allowed by private-allow-ssh)..."
# IMPORTANT: These SSH commands use the IP addresses directly, respecting no DNS.
(while true; do
  # Valid SSH attempt (should succeed from public-vpc to `allow-ssh` tagged private-vpc VM)
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/google_compute_engine "${PRIVATE_LINUX_VM_IP}" "echo 'SSH to private VM from public VM successful - \$(date).'"
  if [ $? -ne 0 ]; then
    logger -t "${PUBLIC_VM_NAME}" "ERROR: Valid SSH attempt to ${PRIVATE_LINUX_VM_IP} failed unexpectedly at $(date)."
  fi
  sleep 5

  # Simulate incorrect user SSH attempt (authentication failure - expected)
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/google_compute_engine "baduser@${PRIVATE_LINUX_VM_IP}" "exit" &> /dev/null
  if [ $? -ne 0 ]; then
    logger -t "${PUBLIC_VM_NAME}" "WARNING: SSH attempt with bad user to ${PRIVATE_LINUX_VM_IP} failed as expected (authentication) at $(date)."
  else
    logger -t "${PUBLIC_VM_NAME}" "CRITICAL: SSH attempt with bad user to ${PRIVATE_LINUX_VM_IP} SUCCEEDED unexpectedly at $(date)."
  fi
  sleep 5
done) &
echo "Public VM SSH load started (PID $!)"

# --- Error Simulation ---

echo "Simulating connection attempt to non-existent port 9999 on private VM (expected to fail, not allowed by firewall)..."
(while true; do
  nc -zv "${PRIVATE_LINUX_VM_IP}" 9999 -w 1 &> /dev/null
  if [ $? -ne 0 ]; then
    logger -t "${PUBLIC_VM_NAME}" "ERROR: Connection attempt to non-existent port 9999 on ${PRIVATE_LINUX_VM_IP} failed at $(date) (expected - no rule for port 9999)."
  else
    logger -t "${PUBLIC_VM_NAME}" "WARNING: Connection attempt to non-existent port 9999 SUCCEEDED unexpectedly on ${PRIVATE_LINUX_VM_IP} at $(date)."
  fi
  sleep 10
done) &
echo "Public VM socket error simulation started (PID $!)"

echo "Simulating an application failure message..."
(while true; do
  logger -t "${PUBLIC_VM_NAME}-app" "ERROR: Critical background service 'WebWorker' encountered an unrecoverable error and terminated at $(date)."
  sleep 30
done) &
echo "Public VM internal application error simulation started (PID $!)"

echo "Public VM simulation scripts are running in the background. Check logs for activity in Cloud Logging."