#!/bin/bash

# Target folder path
TARGET_FOLDER="/home/eidf151/eidf151/username/code/code_deceptive_diffusion/deceptiveDiffusion/$1"

# Transfer yml file
transfer_file='/home/eidf151/eidf151/username/code/code_deceptive_diffusion/yml/transfer.yml'

# File to transfer
PVC_MOUNT_PATH="/mnt/ceph_rbd/deceptiveDiffusion/$1"

# Transfer job name
job_name="example-job"

# Namespace
namespace='eidf151ns'

# Start the transfer job
kubectl -n $namespace apply -f $transfer_file

# Get the pod name of the pod attached to the transfer job
pod_name=$(kubectl -n $namespace get pod -l job-name=$job_name -o jsonpath="{.items[0].metadata.name}")

# Wait for the transfer job to start
kubectl -n $namespace wait --for=condition=Ready pod/$pod_name --timeout=60s

# Create tar file of transfer file on the PVC
kubectl -n $namespace exec "$pod_name" -- tar -cf "$PVC_MOUNT_PATH.tar" -C "$PVC_MOUNT_PATH" .

# Copy the tar file from the PVC
kubectl -n $namespace cp "$pod_name":"$PVC_MOUNT_PATH.tar" "$TARGET_FOLDER.tar"

# Delete the tar file from the PVC
kubectl -n $namespace exec "$pod_name" -- rm "$PVC_MOUNT_PATH.tar"

# Delete the transfer job
kubectl -n $namespace delete -f $transfer_file

# Create the target folder
mkdir -p "$TARGET_FOLDER"

# Extract the contents of the tar file 
tar -xf "$TARGET_FOLDER.tar" -C "$TARGET_FOLDER"

# Delete the tar file
rm "$TARGET_FOLDER.tar"
