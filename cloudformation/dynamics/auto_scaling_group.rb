# Dynamic: auto_scaling_group
# Description: Creates an AWS::AutoScaling::AutoScalingGroup resource
# Parameters:
#   #{_name}_auto_scaling_size
#
# Config: 
#   :launch_configuration_name as ref!
#   :size as number
#
# Outputs:
#   #{_name}_auto_scaling_group_size

SparkleFormation.dynamic(:auto_scaling_group) do |_name, _config={}|

  asg_name = "#{_name}_auto_scaling_group".to_sym 

  parameters("#{_name}_auto_scaling_group_size".to_sym) do
    type 'Number'
    description "Number of desired nodes for #{ asg_name }"
    default _config[:size]
  end

  # Add a load balancer using --apply-stack and output from a
  # load_balancer stack
  parameters("#{_name}_auto_scaling_group_load_balancer_resource_name".to_sym) do
    type 'String'
    description 'The load balancer resource name to associate this AutoScalingGroup with'
    default nil
  end

  resources(asg_name) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      launch_configuration_name _config[:launch_configuration_name]
      max_size ref!("#{_name}_auto_scaling_group_size".to_sym)
      min_size ref!("#{_name}_auto_scaling_group_size".to_sym)
      desired_capacity ref!("#{_name}_auto_scaling_group_size".to_sym)
      load_balancer_names ref!("#{_name}_auto_scaling_group_load_balancer_resource_name".to_sym).join(",")
    end
    creation_policy do
      resource_signal do
        count 1
        timeout "PT10M"
      end
    end
  end

  outputs("#{_name}_auto_scaling_group_max_size".to_sym) do
    description "The MaxSize for the #{ asg_name } AutoScalingGroup"
    value ref!("#{_name}_auto_scaling_group_size".to_sym)
  end

  outputs("#{_name}_auto_scaling_group_min_size".to_sym) do
    description "The MinSize for the #{ asg_name } AutoScalingGroup"
    value ref!("#{_name}_auto_scaling_group_size".to_sym)
  end

  outputs("#{_name}_auto_scaling_group_desired_capacity".to_sym) do
    description "The DesiredCapacity for the #{ asg_name } AutoScalingGroup"
    value ref!("#{_name}_auto_scaling_group_size".to_sym)
  end
end
