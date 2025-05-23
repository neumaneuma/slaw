#!/bin/bash

# List of directories to initialize
DIRS=(
    "management"
    "state"
    "security-audit"
    "iam"
    "log-archive"
    "system-design"
)


for dir in "${DIRS[@]}"; do
    echo "----------------------------------------"
    echo "Initializing Terraform in: $dir"
    echo "----------------------------------------"

    # Change to the directory
    cd "$dir" || continue

    # Run terraform init -upgrade
    terraform init -upgrade

    # Change back to the original directory
    cd - > /dev/null
done
