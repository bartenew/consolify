locals {
  # Decode the JSON input
  parsed_content = jsondecode(var.content)


  # Extract resources based on input type

  normalized_resources = flatten([
    for resource in local.parsed_content.resources : [
      for instance in resource.instances : {
        type     = resource.type
        name     = resource.name
        provider = resource.provider
        attributes = merge(
          instance.attributes,
          {
            # Add region from ARN if missing
            region = lookup(
              instance.attributes,
              "region",
              try(regex("^arn:aws:[^:]+:([^:]+):", lookup(instance.attributes, "arn", ""))[0], null)
            )
          }
        )
      }
    ]
  ])


  console_host = "console.aws.amazon.com"
  # Define mappable resource types with properties required to construct links
  linkable_resources_map = {
    # S3 Bucket
    aws_s3_bucket = {
      fmt = "https://s3.${local.console_host}/s3/buckets/$${bucket}?region=$${region}&tab=objects"
    }

    # Lambda Function
    aws_lambda_function = {
      fmt = "https://${local.console_host}/lambda/home?region=$${region}#/functions/$${function_name}"
    }

    # EC2 Instance
    aws_instance = {
      fmt = "https://${local.console_host}/ec2/v2/home?region=$${region}#Instances:instanceId=$${id}"
    }

    # DynamoDB Table
    aws_dynamodb_table = {
      fmt = "https://${local.console_host}/dynamodb/home?region=$${region}#table?name=$${table_name}"
    }

    # RDS Cluster
    aws_rds_cluster = {
      fmt = "https://${local.console_host}/rds/home?region=$${region}#database:id=$${cluster_identifier};is-cluster=true"
    }

    # RDS Instance
    aws_db_instance = {
      fmt = "https://${local.console_host}/rds/home?region=$${region}#database:id=$${id};is-cluster=false"
    }

    # EKS Cluster
    aws_eks_cluster = {
      fmt = "https://${local.console_host}/eks/home?region=$${region}#/clusters/$${name}"
    }

    # DMS Task
    aws_dms_replication_task = {
      fmt = "https://${local.console_host}/dms/v2/home?region=$${region}#tasks:ids=$${replication_task_id}"
    }

    # DMS Instance
    aws_dms_replication_instance = {
      fmt = "https://${local.console_host}/dms/v2/home?region=$${region}#replicationInstances:ids=$${replication_instance_id}"
    }

    # OpenSearch Domain
    aws_opensearch_domain = {
      fmt = "https://${local.console_host}/aos/home?region=$${region}#/opensearch/domains/$${domain_name}"
    }

    # Log Group
    aws_cloudwatch_log_group = {
      fmt = "https://${local.console_host}/cloudwatch/home?region=$${region}#logsV2:log-groups/log-group/$${urlencode(name)}"
    }

    # API Gateway
    aws_apigatewayv2_api = {
      fmt = "https://${local.console_host}/apigateway/main/apis/$${id}/overview?region=$${region}"
    }

    # AWS AppConfig
    aws_appconfig_application = {
      fmt = "https://${local.console_host}/systems-manager/appconfig/applications/$${id}?region=$${region}"
    }

    # Lambda Layer
    aws_lambda_layer_version = {
      fmt = "https://${local.console_host}/lambda/home?region=$${region}#/layers/$${layer_name}/versions/$${version}"
    }
    aws_iam_role = {
      fmt = "https://${local.console_host}/iam/home#/roles/details/$${urlencode(name)}"
    }
  }

  linkable_resources = var.enabled ? [
    for resource in local.normalized_resources :
    {
      address = "${resource.type}.${resource.name}"
      link = templatestring(
        local.linkable_resources_map[resource.type].fmt, resource.attributes
      )
    } if contains(keys(local.linkable_resources_map), resource.type)
  ] : []
}
