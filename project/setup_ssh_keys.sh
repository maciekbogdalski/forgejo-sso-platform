#!/bin/bash

# Define variables
NUM_TARGET=2
MYNET=192.168.177
SSH_KEY_PATH="/home/vagrant/.ssh/id_rsa_vcc"

# Function to wait for SSH service on target VMs
wait_for_ssh() {
  local host=$1
  local max_retries=10
  local retries=0
  until sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 vagrant@$host 'echo SSH is up' 2>/dev/null; do
    retries=$((retries + 1))
    if [ $retries -ge $max_retries ]; then
      echo "SSH not available on $host after $retries attempts, exiting."
      exit 1
    fi
    echo "Waiting for SSH on $host..."
    sleep 15
  done
}

# Add hosts to known_hosts and distribute SSH keys
for i in $(seq 1 $NUM_TARGET); do
  HOST_IP=${MYNET}.$((i+10))
  echo "Adding $HOST_IP to known_hosts"
  ssh-keyscan -H $HOST_IP >> ~/.ssh/known_hosts
  wait_for_ssh $HOST_IP
  echo "Attempting to copy SSH key to $HOST_IP"
  sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no -f -i $SSH_KEY_PATH.pub vagrant@$HOST_IP
done

# Ensure control VM can SSH to itself
ssh-keyscan -H ${MYNET}.10 >> ~/.ssh/known_hosts
sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no -f -i $SSH_KEY_PATH.pub vagrant@${MYNET}.10

echo "SSH key distribution complete."
