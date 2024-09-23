#!/bin/bash

# Function to remove trailing slash if present
normalize_path() {
  echo "$1" | sed 's:/*$::'
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <yaml_cronjobs_folder_path> <file_prefix> <output_folder>"
  exit 1
fi

# Normalize the paths to ensure no trailing slash
yaml_cronjobs_folder_path=$(normalize_path "$1")
file_prefix=$2
output_folder=$(normalize_path "$3")

# Loop through all files with the .yml extension in the folder
for file in "${yaml_cronjobs_folder_path}/${file_prefix}"*.yml; do
  # Extract the filename without extension
  filename="${file##*/}"
  # Remove the .yml extension from filename
  filename="${filename%.yml}"
    # Remove the .yaml extension from filename
  filename="${filename%.yml}"
  
  # Run the k2tf command with the current file and output filename
  k2tf -f "$file" -o "${output_folder}/${filename}.tf"
  
  echo "Converted $file to ${filename}.tf"
done
