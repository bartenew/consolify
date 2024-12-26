variables {
  enabled = true
}

run "state_1" {
  variables {
    content = file("tests/state1.json")
  }
  command = plan

  assert {
    condition = alltrue([
      for resource in output.linkable_resources :
      can(regex("^(https?)://[\\w.-]+(?:\\.[a-z]+)+.*$", resource.link))
    ])
    error_message = "Links should exist"
  }

  assert {
    condition = anytrue([
      for resource in output.linkable_resources : (resource.address == "aws_cloudwatch_log_group.example" && can(regex(".*cloudwatch.*", resource.link)))
    ])
    error_message = "Cloudwatch log group link"
  }

  assert {
    condition = anytrue([
      for resource in output.linkable_resources : (resource.address == "aws_instance.nano_count_2" && can(regex(".*ec2.*", resource.link)))
    ])
    error_message = "Cloudwatch log group link"
  }
}


