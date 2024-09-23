# Terraform Resource Import Helper

The `terraform-resource-import-helper.sh` script is designed to simplify and automate the process of importing existing resources into Terraform. By extracting relevant information from your `.tf` files, it generates the necessary `terraform import` commands, making it easier to migrate your infrastructure into Terraform management.

## Overview

This handy script scans a specified directory for Terraform files that match a given prefix and pulls out essential resource information. It then prints out the corresponding `terraform import` commands, so you can seamlessly import your existing resources with minimal effort.

## Features

- **Path Normalization**: Automatically removes any trailing slashes from the provided folder path to help prevent errors during execution.
- **Resource Extraction**: Grabs key details like resource type, resource name, namespace, and metadata name from your Terraform files.
- **Custom Import Handling**: Special support for KEDA `ScaledObject` resources, generating import commands with the correct syntax.
- **Import Command Generation**: Outputs the exact `terraform import` commands you need to import resources into your Terraform state.

## Usage

### Problems
- When using terragrunt in your projects, you need to actually import your resources before making them generic, I have this problem myself where I do not want to duplicate code for dev and production environment but when converting yaml to terraform and importing resources, I then have to do some manual steps to account for both namespaces.

### Prerequisites

- Make sure you have Terraform installed on your system. You can find installation instructions [here](https://www.terraform.io/downloads.html).

### Script Parameters

To use the script, you'll need to provide two parameters:

1. **folder_path**: The path to the folder containing your `.tf` files.
2. **file_prefix**: The prefix of the `.tf` files you want to process (for example, `cronjob_`).

### Example Command

Here's how you can run the script:

```bash
./terraform-resource-import-helper.sh /path/to/tf/folder cronjob_
