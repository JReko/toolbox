#!/bin/bash

# Function to normalize paths (remove trailing slashes)
normalize_path() {
  echo "$1" | sed 's:/*$::'
}

# Function to extract resource information from a file
extract_resource_info() {
  local filename="$1"

  # Get all resource blocks in the file
  local resource_blocks
  resource_blocks=$(grep -n 'resource\s*"' "$filename")

  # Count the number of resource blocks
  local block_count=$(echo "$resource_blocks" | wc -l)

  if [[ $block_count -eq 0 ]]; then
    echo "ERROR: No resource blocks found in $filename"
    return
  fi

  # If there's more than one block, process each one
  if [[ $block_count -gt 1 ]]; then
    loop_index=1
    # Loop through each resource block
    while IFS= read -r block; do
      local resource_type=$(grep -oP 'resource\s*"\K[^"]+' "$filename" | head -n "$loop_index" | tail -n 1)
      local resource_name=$(grep -oP 'resource\s*"[^"]+"\s*"\K[^"]+' "$filename" | head -n "$loop_index" | tail -n 1)
      local metadata_namespace=$(hcl2json "$filename"| jq -r '.resource[].[].[].metadata[].namespace' | head -n "$loop_index" | tail -n 1)
      local metadata_name=$(hcl2json "$filename"| jq -r '.resource[].[].[].metadata[].name' | head -n "$loop_index" | tail -n 1)
      local api_version=$(grep -oP '"apiVersion"\s*=\s*"\K[^"]+' "$filename" | head -n "$loop_index" | tail -n 1)
      local kind=$(grep -oP '"kind"\s*=\s*"\K[^"]+' "$filename" | head -n "$loop_index" | tail -n 1)

      # Ensure variables are not empty for standard resources
      if [[ -z "$resource_type" || -z "$resource_name" || -z "$metadata_name" || -z "$metadata_namespace" ]]; then
        echo "ERROR: $filename doesn't respect expected format for block starting at line $line_number"
        continue
      fi

      if [[ "$api_version" == "keda.sh/v1alpha1" && "$kind" == "ScaledObject" ]]; then
        # Special case for ScaledObject
        echo "terragf import $resource_type.$resource_name \"apiVersion=$api_version,kind=$kind,namespace=$metadata_namespace,name=$metadata_name\""
      elif [[ "$api_version" == "traefik.io/v1alpha1" && "$kind" == "IngressRoute" ]]; then
        # Special case for ScaledObject
        echo "terragf import $resource_type.$resource_name \"apiVersion=$api_version,kind=$kind,namespace=$metadata_namespace,name=$metadata_name\""
      else
        # General case
        echo "terragf import $resource_type.$resource_name $metadata_namespace/$metadata_name"
      fi

      ((loop_index++))
    done <<< "$resource_blocks"
  else
    # Handle single resource block as before
    local resource_type=$(grep -oP 'resource\s*"\K[^"]+' "$filename" | head -n 1)
    local resource_name=$(grep -oP 'resource\s*"[^"]+"\s*"\K[^"]+' "$filename" | head -n 1)
    local metadata_namespace=$(grep -oP '"?namespace"?\s*=\s*"\K[^"]+' "$filename" | head -n 1)
    local metadata_name=$(grep -oP '"?name"?\s*=\s*"\K[^"]+' "$filename" | head -n 1)
    local api_version=$(grep -oP '"apiVersion"\s*=\s*"\K[^"]+' "$filename" | head -n 1)
    local kind=$(grep -oP '"kind"\s*=\s*"\K[^"]+' "$filename" | head -n 1)

    # Ensure variables are not empty for standard resources
    if [[ -z "$resource_type" || -z "$resource_name" || -z "$metadata_name" || -z "$metadata_namespace" ]]; then
      echo "ERROR: $filename doesn't respect expected format"
      return
    fi

    if [[ "$api_version" == "keda.sh/v1alpha1" && "$kind" == "ScaledObject" ]]; then
      # Special case for ScaledObject
      echo "terragf import $resource_type.$resource_name \"apiVersion=$api_version,kind=$kind,namespace=$metadata_namespace,name=$metadata_name\""
    elif [[ "$api_version" == "traefik.io/v1alpha1" && "$kind" == "IngressRoute" ]]; then
        # Special case for ScaledObject
        echo "terragf import $resource_type.$resource_name \"apiVersion=$api_version,kind=$kind,namespace=$metadata_namespace,name=$metadata_name\""
    else
      # General case
      echo "terragf import $resource_type.$resource_name $metadata_namespace/$metadata_name"
    fi
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
    extract_resource_info "$filename"
  fi
done
