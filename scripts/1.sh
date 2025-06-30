# Phase 1: Local Setup Script
# Phase 1: Local Setup Script
# This script initializes the MySQL server on {SUB_MYSQL_SERVER_VM} and installs the MySQL client on {SUB_MYSQL_CLIENT_VM}. # # Run this from your local machine with gcloud CLI installed and authenticated.

# File: setup_gcp_environment.sh or 1.sh
#!/bin/bash
# setup_gcp_environment.sh
# This script configures MySQL server and client on the respective VMs.
# Run this locally from your machine.

PROJECT_ID="{SUB_PROJECT_ID}"
ZONE="{SUB_ZONE}"

MYSQL_SERVER_VM="{SUB_MYSQL_SERVER_VM}" # Used for gcloud command, gcloud handles name resolution here
MYSQL_CLIENT_VM="{SUB_MYSQL_CLIENT_VM}" # Used for gcloud command, gcloud handles name resolution here

echo "--- Setting up MySQL Server on ${MYSQL_SERVER_VM} (${ZONE}) ---"
# Note: gcloud compute ssh handles name resolution for the initial connection from your local machine.
# Internal VM-to-VM SSH commands in other scripts use IP addresses directly.
gcloud compute ssh "${MYSQL_SERVER_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" << EOF
  echo "Updating apt package list..."
  sudo apt-get update -y
  echo "Installing mysql-server..."
  sudo apt-get install -y default-mysql-server
  echo "Starting mysql service..."
  sudo systemctl start mysql
  # Create a test database and user accessible from any host (%) for simulation purposes.
  # In a real environment, restrict 'testuser' to specific client IPs (e.g., 'testuser'@'10.1.1.%')
  echo "Creating MySQL database 'testdb' and user 'testuser'..."
  sudo mysql -e "CREATE DATABASE IF NOT EXISTS testdb; \
                 CREATE USER 'testuser'@'%' IDENTIFIED BY 'testpassword'; \
                 GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'%'; \
                 FLUSH PRIVILEGES;"
  echo "MySQL server setup complete."
EOF
if [ $? -ne 0 ]; then echo "Error setting up MySQL Server. Aborting."; fi

echo ""
echo "--- Setting up MySQL Client on ${MYSQL_CLIENT_VM} (${ZONE}) ---"
gcloud compute ssh "${MYSQL_CLIENT_VM}" --zone "${ZONE}" --project "${PROJECT_ID}" << EOF
  echo "Updating apt package list..."
  sudo apt-get update -y
  echo "Installing mysql-client..."
  sudo apt-get install -y mysql-client
  echo "MySQL client setup complete."
EOF
if [ $? -ne 0 ]; then echo "Error setting up MySQL Client. Aborting."; fi

echo ""
echo "Environment setup complete. You can now run the simulation scripts."