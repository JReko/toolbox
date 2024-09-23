#!/bin/bash

# Function to normalize paths (remove trailing slashes)
normalize_path() {
  echo "$1" | sed 's:/*$::'
}

# Function to extract resource information from a file
extract_resource_info() {
  local filename="$1"
  local resource_type
  local resource_name
  local metadata_namespace
  local metadata_name
  local api_version
  local kind

  # Extract resource type (first string between double quotes after resource)
  resource_type=$(grep -oP 'resource\s*"\K[^"]+' "$filename" | head -n 1)

  # Extract resource name (second string between double quotes after resource)
  resource_name=$(grep -oP 'resource\s*"[^"]+"\s*"\K[^"]+' "$filename" | head -n 1)

  # Extract metadata namespace (string after namespace = under metadata)
  metadata_namespace=$(grep -oP '"?namespace"?\s*=\s*"\K[^"]+' "$filename" | head -n 1)

  # Extract metadata name (string after name = under metadata)
  metadata_name=$(grep -oP '"?name"?\s*=\s*"\K[^"]+' "$filename" | head -n 1)

  # Extract apiVersion and kind for special cases like ScaledObject
  api_version=$(grep -oP '"apiVersion"\s*=\s*"\K[^"]+' "$filename" | head -n 1)
  kind=$(grep -oP '"kind"\s*=\s*"\K[^"]+' "$filename" | head -n 1)

  # Ensure variables are not empty for standard resources
  if [[ -z "$resource_type" || -z "$resource_name" || -z "$metadata_name" || -z "$metadata_namespace" ]]; then
    return 1  # Return non-zero status if any extraction failed
  fi

  # Return all extracted values including apiVersion and kind
  echo "$resource_type $resource_name $metadata_namespace $metadata_name $api_version $kind"
}

# Function to print the terraform import command
print_terraform_import_command() {
  local resource_type="$1"
  local resource_name="$2"
  local metadata_namespace="$3"
  local metadata_name="$4"
  local api_version="$5"
  local kind="$6"

  if [[ "$api_version" == "keda.sh/v1alpha1" && "$kind" == "ScaledObject" ]]; then
    # Special case for ScaledObject
    echo "terragf import $resource_type.$resource_name \"apiVersion=$api_version,kind=$kind,namespace=$metadata_namespace,name=$metadata_name\""
  else
    # General case
    echo "terragf import $resource_type.$resource_name $metadata_namespace/$metadata_name"
  fi
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <folder_path> <file_prefix>"
  exit 1
fi

# Normalize the folder path (remove trailing slashes) and get the file prefix
folder_path=$(normalize_path "$1")
file_prefix="$2"

# Adjust for all files if * is passed as file_prefix
if [[ "$file_prefix" == "*" ]]; then
  file_prefix=".*"
else
  file_prefix="^$file_prefix"
fi

# Loop through all .tf files in the folder
for filename in "$folder_path"/*.tf; do
  base_filename=$(basename "$filename")

  # Process only files matching the specified prefix or all files if * is passed
  if [[ "$base_filename" =~ $file_prefix ]]; then
    # Extract resource information

    resource_info=$(extract_resource_info "$filename")

    if [[ $? -eq 0 ]]; then
      # Read resource information into separate variables
      read -r resource_type resource_name metadata_namespace metadata_name api_version kind <<< "$resource_info"

      # Print the terraform import command
      print_terraform_import_command "$resource_type" "$resource_name" "$metadata_namespace" "$metadata_name" "$api_version" "$kind"
    else
      echo "Failed to extract resource info from $filename"
    fi
  fi
done
