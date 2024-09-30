#!/bin/bash

# Function to remove trailing slash if present
normalize_path() {
  echo "$1" | sed 's:/*$::'
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <yaml_jobs_folder_path> <file_prefix> <output_folder>"
  exit 1
fi

# Normalize the paths to ensure no trailing slash
yaml_folder_path=$(normalize_path "$1")
file_prefix=$2
output_folder=$(normalize_path "$3")

# Handle the case where the user passes "*" meaning no prefix (all .yml/.yaml files)
if [ "$file_prefix" == "*" ]; then
  file_prefix=""
fi

# Function to process files based on the extension and prefix
process_files() {
  local extension=$1

  # Loop through files with the given extension
  for file in "${yaml_folder_path}/${file_prefix}"*"$extension"; do
    # Ensure the file exists
    if [ -f "$file" ]; then
      # Extract the filename without extension
      filename="${file##*/}"
      # Remove the extension from filename
      filename="${filename%$extension}"

      # Check if the file is prefixed with "ingress" or "scaler"
      if [[ "$filename" == ingress* || "$filename" == scaler* ]]; then
        # Use tfk8s for ingress or scaler files
        tfk8s generate -f "$file" > "${output_folder}/${filename}.tf"
        echo "Converted $file to ${filename}.tf using tfk8s"
      else
        # Use k2tf for other files
        k2tf -f "$file" -o "${output_folder}/${filename}.tf"
        echo "Converted $file to ${filename}.tf using k2tf"
      fi
    fi
  done
}

# Process .yml files
process_files ".yml"

# Process .yaml files
process_files ".yaml"
