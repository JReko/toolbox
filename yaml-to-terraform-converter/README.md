# YAML to Terraform Converter

This script batch converts Kubernetes YAML configuration files into Terraform files. It simplifies the management of infrastructure as code by enabling users to easily convert their existing YAML configurations into Terraform syntax.

## Overview

The `yaml-to-terraform-converter.sh` script scans a specified directory for YAML files matching a given prefix and converts each file into a Terraform file using the `k2tf` tool. The resulting Terraform files are saved in a specified output directory.

## Features

- **Path Normalization**: Automatically removes trailing slashes from provided paths to prevent errors.
- **Batch Processing**: Converts all matching YAML files in a specified folder.
- **User-Friendly Output**: Prints success messages for each conversion, making it easy to track progress.

## Usage

### Prerequisites

- Ensure you have `k2tf` installed on your system. https://github.com/sl1pm4t/k2tf

### Script Parameters

To use the script, you need to provide three parameters:

1. **yaml_cronjobs_folder_path**: The path to the folder containing your YAML cronjob files.
2. **file_prefix**: The prefix of the YAML files you want to convert (e.g., `testing`).
3. **output_folder**: The folder where the converted Terraform files will be saved.

### Example Command

```bash
./yaml-to-terraform-converter.sh /path/to/yaml/folder file_prefix /path/to/output/folder
```
