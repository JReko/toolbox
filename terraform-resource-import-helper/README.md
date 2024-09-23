# Terraform Resource Import Helper

The `terraform-resource-import-helper.sh` script simplifies and batches the process of importing existing resources into Terraform by extracting relevant information from `.tf` files and generating the appropriate `terraform import` commands. This tool is particularly useful for migrating existing infrastructure into Terraform management.

## Overview

This script scans a specified directory for Terraform files that match a given prefix and extracts essential resource information. It then prints out the corresponding `terraform import` commands, enabling users to import their existing resources easily.

## Features

- **Path Normalization**: Automatically removes trailing slashes from the provided folder path to prevent errors.
- **Resource Extraction**: Extracts resource type, resource name, namespace, and metadata name from the Terraform files.
- **Import Command Generation**: Outputs the exact `terraform import` commands needed to import resources into your Terraform state.

## Usage

### Prerequisites

- Ensure that you have Terraform installed on your system. You can find installation instructions [here](https://www.terraform.io/downloads.html).

### Script Parameters

To use the script, you need to provide two parameters:

1. **folder_path**: The path to the folder containing your `.tf` files.
2. **file_prefix**: The prefix of the `.tf` files you want to process (e.g., `cronjob_`).

### Example Command

```bash
./terraform-resource-import-helper.sh /path/to/tf/folder cronjob_
```
