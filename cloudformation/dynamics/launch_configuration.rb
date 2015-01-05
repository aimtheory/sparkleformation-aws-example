# Dynamic: launch_configuration
# Description: Creates an AWS::AutoScaling::LaunchConfiguration
# resource
# Config:
#   :image_id as string
#   :instance_type as string
#   :security_groups as array of ref!s
#
# Parameters:
#   "#{lc_name}_image_id" as string
#   "#{lc_name}_instance_type" as string
#   "#{lc_name}_security_groups" as comma delimited list
#
# Outputs:
#   image_id as string
#   instance_type as string
#   key_name as string
#   security_groups as comma delimited list

SparkleFormation.dynamic(:launch_configuration) do |_name, _config={}|

  lc_name = "#{_name}_launch_configuration"

  parameters do

    set!("#{lc_name}_image_id".to_sym) do
      type 'String'
      description "ImageID for the LaunchConfiguration resource"
      default _config[:image_id] || 'ami-59a4a230'
    end

    set!("#{lc_name}_instance_type".to_sym) do
      type 'String'
      description "InstanceType for the LaunchConfiguration resource"
      default _config[:instance_type] || 'm1.small'
    end

  end

  resources("#{_name}_launch_wait_handle".to_sym) do
    type 'AWS::CloudFormation::WaitConditionHandle'
  end

  resources(lc_name.to_sym) do
    type 'AWS::AutoScaling::LaunchConfiguration'
    properties do
      image_id ref!("#{lc_name}_image_id".to_sym)
      instance_type ref!("#{lc_name}_instance_type".to_sym)
      key_name _config[:key_name] || ref!(:key_name)
      security_groups [ _config[:security_group] ] || []
      user_data base64!(
                        join!(
                              "#!/bin/bash\n",
                              "apt-get -y install python-setuptools\n",
                              "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                              "cfn-init -v --region ",
                              ref!('AWS::Region'),
                              " -s ",
                              ref!('AWS::StackName'),
                              " -r #{ _process_key(lc_name.to_sym) }",
                              "\n",
                              "cfn-signal -e $? --stack ",
                              ref!("AWS::StackName"),
                              " '",
                              ref!("#{_name}_launch_wait_handle".to_sym),
                              "'\n"
                              )
                        )
    end
  end

  outputs do

    set!("#{lc_name}_image_id".to_sym) do
      description "The ImageID for the LaunchConfiguration resource"
      value ref!("#{lc_name}_image_id".to_sym)
    end

    set!("#{lc_name}_instance_type".to_sym)do
      description "The InstanceType for the LaunchConfiguration resource"
      value ref!("#{lc_name}_instance_type".to_sym)
    end

    key_name do
      description 'The KeyName for the LaunchConfiguration resource'
      value _config[:key_name] || ref!(:key_name)
    end

    # set!("#{lc_name}_security_group".to_sym)do
    #   description "The SecurityGroup for the LaunchConfiguration resource"
    #   value ref!("#{lc_name}_security_group".to_sym)
    # end

  end

end
