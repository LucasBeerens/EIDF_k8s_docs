#!/bin/bash

# Source folder path
SOURCE_FOLDER="/home/eidf151/eidf151/username/code/code_deceptive_diffusion/deceptiveDiffusion/"

# Transfer yml file
transfer_file='/home/eidf151/eidf151/username/code/code_deceptive_diffusion/yml/transfer.yml'

# PVC mount path
PVC_MOUNT_PATH="/mnt/ceph_rbd/deceptiveDiffusion/"

# Transfer job name
job_name="example-job"

# Namespace
namespace='eidf151ns'

# Create a temporary tar file
TEMP_TAR_FILE="/tmp/folder.tar"
tar --exclude="$SOURCE_FOLDER model/*" -cf "$TEMP_TAR_FILE" -C "$SOURCE_FOLDER" .

# Create the transfer job
kubectl -n $namespace apply -f $transfer_file

# Get the pod name of the pod attached to the transfer job
pod_name=$(kubectl -n $namespace get pod -l job-name=$job_name -o jsonpath="{.items[0].metadata.name}")

# Wait for the transfer job to start
kubectl -n $namespace wait --for=condition=Ready pod/$pod_name --timeout=60s

# Create directory on the PVC if it doesn't exist
kubectl -n $namespace exec "$pod_name" -- mkdir -p "$PVC_MOUNT_PATH"

# Copy the tar file to the PVC
kubectl -n $namespace cp "$TEMP_TAR_FILE" "$pod_name":"$PVC_MOUNT_PATH"

# Extract the contents of the tar file on the PVC
kubectl -n $namespace exec "$pod_name" -- tar -xf "$PVC_MOUNT_PATH/folder.tar" -C "$PVC_MOUNT_PATH"

# Clean up the temporary tar file
rm "$TEMP_TAR_FILE"

# Delete the tar file from the PVC
kubectl -n $namespace exec "$pod_name" -- rm "$PVC_MOUNT_PATH/folder.tar"

# Delete the transfer job
kubectl -n $namespace delete -f $transfer_file

