# AWS Console Link Generator

This project parses **Terraform state JSON** to extract and print AWS Console links for resources managed by Terraform. It currently supports the **AWS provider** and focuses on generating convenient links for easy navigation to AWS resources in the console.

![img.png](https://github.com/bartenew/terraform-aws-consolify/blob/main/img/img.png?raw=true)

## Features

- Parses **Terraform state JSON** files to identify AWS resources.
- Generates **AWS Console links** for supported resource types.
- Simple and intuitive output for quick navigation.
- Supports filtering by specific resource types or names.

## Supported Providers

- **AWS** (current support only).

## Usage

```terraform


# state must not be null before you apply
data "terraform_remote_state" "state" {
  backend = "local" # s3 or any kind of backend
  config = {
    path = "terraform.tfstate"
  }
}

module "consolify" {
  source  = "bartenew/consolify/aws"
  version = "1.0.3"
  content = file(data.terraform_remote_state.state.config.path)
}

```
## Limitations

- **Provider Support**: Currently, only the AWS provider is supported. Other cloud providers may be added in the future.
- **Resource Types**: Not all AWS resource types may have link generation logic implemented yet.

## Contributing

We welcome contributions to improve this project, including:
- Adding support for more AWS resource types.
- Extending functionality to support additional Terraform providers.

Feel free to open issues or submit pull requests!

