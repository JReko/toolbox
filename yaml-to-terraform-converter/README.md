# YAML to Terraform Converter

This script batch converts Kubernetes YAML configuration files into Terraform files. It simplifies the management of infrastructure as code by enabling users to easily convert their existing YAML configurations into Terraform syntax. It also handles certain special resource types like KEDA `ScaledObject` and Traefik `IngressRoute` with appropriate conversion tools.

## Overview

The `yaml-to-terraform-converter.sh` script scans a specified directory for YAML files matching a given prefix and converts each file into a Terraform file using the `k2tf` or `tfk8s` tool, depending on the resource type. The resulting Terraform files are saved in a specified output directory.

## Features

- **Path Normalization**: Automatically removes trailing slashes from provided paths to prevent errors.
- **Handling Special Resources**: Automatically switches to `tfk8s` for certain resource types like KEDA `ScaledObject` or Traefik `IngressRoute` that can't be converted by `k2tf`.
- **Batch Processing**: Converts all matching YAML files in a specified folder.
- **User-Friendly Output**: Prints success messages for each conversion, making it easy to track progress.

## Special Handling of KEDA ScaledObject and Traefik IngressRoute

Some Kubernetes resources, such as KEDA `ScaledObject` and Traefik `IngressRoute`, are not handled by the `k2tf` tool. When the script detects files prefixed with `scaler` (typically for KEDA `ScaledObject`) or `ingress` (typically for Traefik `IngressRoute`), it automatically switches from `k2tf` to `tfk8s` for the conversion. This ensures that these special resource types are properly converted without errors.

If you’re working with custom Kubernetes resources that can’t be parsed by `k2tf`, such as:

- **KEDA**: `ScaledObject` resource (`keda.sh/v1alpha1`)
- **Traefik**: `IngressRoute` resource (`traefik.io/v1alpha1`)

The script will handle this for you, ensuring these types are converted using `tfk8s`, which is capable of handling custom resource definitions (CRDs).

## Usage

### Prerequisites

- Ensure you have `k2tf` installed on your system. [k2tf GitHub Repository](https://github.com/sl1pm4t/k2tf)
- Ensure you have `tfk8s` installed for converting certain custom Kubernetes resources. [tfk8s GitHub Repository](https://github.com/dirien/tfk8s)

### Script Parameters

To use the script, you need to provide three parameters:

1. **yaml_cronjobs_folder_path**: The path to the folder containing your YAML cronjob files.
2. **file_prefix**: The prefix of the YAML files you want to convert (e.g., `testing` or `ingress`). You can pass `*` to match all YAML files in the folder.
3. **output_folder**: The folder where the converted Terraform files will be saved.

### Example Command

```bash
./yaml-to-terraform-converter.sh /path/to/yaml/folder file_prefix /path/to/output/folder
