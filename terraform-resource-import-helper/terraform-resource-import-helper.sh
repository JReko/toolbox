#!/bin/bash

# Function to normalize paths (remove trailing slashes)
normalize_path() {
  echo "$1" | sed 's:/*$::'
}

# Function to extract resource information from a file
function extract_resource_info() {
  local filename="$1"
  local resource_type
  local resource_name
  local metadata_namespace
  local metadata_name

  # Extract resource type (first string between double quotes after resource)
  resource_type=$(grep -oP 'resource\s*"\K[^"]+' "$filename")

  # Extract resource name (second string between double quotes after resource)
  resource_name=$(grep -oP 'resource\s*"[^"]+"\s*"\K[^"]+' "$filename")

  # Extract metadata name (string after name = under metadata)
  metadata_name=$(grep -oP 'name\s*=\s*"\K[^"]+' "$filename")

  # Extract metadata namespace (string after namespace = under metadata)
  metadata_namespace=$(grep -oP 'namespace\s*=\s*"\K[^"]+' "$filename")

  # Ensure variables are not empty
  if [[ -z "$resource_type" || -z "$resource_name" || -z "$metadata_name" || -z "$metadata_namespace" ]]; then
    return 1  # Return non-zero status if any extraction failed
  fi

  # Return all extracted values
  echo "$resource_type $resource_name $metadata_namespace $metadata_name"
}

# Function to print the terraform import command
function print_terraform_import_command() {
  local resource_type="$1"
  local resource_name="$2"
  local metadata_namespace="$3"
  local metadata_name="$4"

  # using terragf as a command myself terragf is a simple script to use terragrunt when possible otherwise terraform
  # https://github.com/DaazKu/unix-setup/blob/master/%24HOME/bin/terragf

  echo "terragf import $resource_type.$resource_name $metadata_namespace/$metadata_name"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <folder_path> <file_prefix>"
  exit 1
fi

# Normalize the folder path (remove trailing slashes) and get the file prefix
folder_path=$(normalize_path "$1")
file_prefix="$2"

# Loop through all .tf files in the folder
for filename in "$folder_path"/*.tf; do
  base_filename=$(basename "$filename")

  # Process only files starting with the specified prefix
  if [[ "$base_filename" =~ ^$file_prefix ]]; then
    # echo "Processing file: $filename"
    
    # Extract resource information
    resource_info=$(extract_resource_info "$filename")

    if [[ $? -eq 0 ]]; then
      # Read resource information into separate variables
      read -r resource_type resource_name metadata_namespace metadata_name <<< "$resource_info"

      # Print the terraform import command
      print_terraform_import_command "$resource_type" "$resource_name" "$metadata_namespace" "$metadata_name"
    else
      echo "Failed to extract resource info from $filename"
    fi
  fi
done
