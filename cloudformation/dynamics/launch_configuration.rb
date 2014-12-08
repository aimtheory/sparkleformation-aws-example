# Dynamic: launch_configuration
# Description: Creates an AWS::AutoScaling::LaunchConfiguration
# resource
# Config:
#   :image_id as string
#   :instance_type as string
#   :key_name as string
#   :security_groups as array of ref!s
#
# Parameters:
#   image_id as string
#   instance_type as string
#   key_name as string
#   security_groups as comma delimited list
#
# Outputs:
#   #{_name}_launch_configuration as string
#   image_id as string
#   instance_type as string
#   key_name as string
#   security_groups as comma delimited list

SparkleFormation.dynamic(:launch_configuration) do |_name, _config={}|

  lc_name = "#{_name}_launch_configuration".to_sym

  parameters("#{_name}_launch_configuration_image_id".to_sym) do
    type 'String'
    description "ImageID for #{ lc_name }"
    default _config[:image_id] || 'ami-59a4a230'
  end

  parameters("#{_name}_launch_configuration_instance_type".to_sym) do
    type 'String'
    description "InstanceType for #{ lc_name }"
    default _config[:instance_type] || 'm1.small'
  end 

  parameters("#{_name}_launch_configuration_key_name".to_sym) do
    type 'String'
    description "KeyName for #{ lc_name }"
    default _config[:key_name] || 'sparkleinfrakey'
  end

  resources(lc_name) do
    type 'AWS::AutoScaling::LaunchConfiguration'
    properties do
      image_id ref!("#{_name}_launch_configuration_image_id".to_sym)
      instance_type ref!("#{_name}_launch_configuration_instance_type".to_sym)
      key_name ref!("#{_name}_launch_configuration_key_name".to_sym)
      security_groups _config[:security_groups] || []
      user_data base64!(
                        join!(
                              '#!/bin/bash\n',
                              'cfn-init -v --region ',
                              ref!('AWS::Region'),
                              ' -s ',
                              ref!('AWS::StackName'),
                              " -r #{_process_key(_config[:launch_config_name])} --access-key ",
                              ref!(:cfn_keys),
                              ' --secret-key ',
                              attr!(:cfn_keys, :secret_access_key),
                              "\n",
                              "cfn-signal -e $? --stack ",
                              ref!("AWS::StackName"),
                              " --resource AutoScalingGroup\n"
                              )
                        )
    end
  end

  outputs("#{_name}_launch_configuration_image_id".to_sym) do
    description "The ImageID for the #{ lc_name } LaunchConfiguration resource"
    value ref!("#{_name}_launch_configuration_image_id".to_sym)
  end

  outputs("#{_name}_launch_configuration_instance_type".to_sym) do
    description "The InstanceType for the #{ lc_name } LaunchConfiguration resource"
    value ref!("#{_name}_launch_configuration_instance_type".to_sym)
  end

  outputs("#{_name}_launch_configuration_key_name".to_sym) do
    description 'The KeyName for the #{ lc_name } LaunchConfiguration resource'
    value ref!("#{_name}_launch_configuration_key_name".to_sym)
  end

  outputs("#{_name}_launch_configuration_security_groups".to_sym) do
    description "The SecurityGroups for the #{ lc_name } LaunchConfiguration resource"
    value _config[:security_groups].join(",")
  end

end
