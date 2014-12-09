# Dynamic: auto_scaling_group
# Description: Creates an AWS::AutoScaling::AutoScalingGroup resource
# Parameters:
#   #{_name}_auto_scaling_group_max_size
#   #{_name}_auto_scaling_group_min_size
#
# Config: 
#   :launch_configuration_name as ref!
#   :max_size as number
#   :min_size as number
#
# Outputs:
#   #{_name}_auto_scaling_group_max_size
#   #{_name}_auto_scaling_group_min_size 

SparkleFormation.dynamic(:auto_scaling_group) do |_name, _config={}|

  asg_name = "#{_name}_auto_scaling_group".to_sym 

  parameters("#{_name}_auto_scaling_group_max_size".to_sym) do
    type 'Number'
    description "Max nodes for #{ asg_name }"
    default 2
  end

  parameters("#{_name}_auto_scaling_group_min_size".to_sym) do
    type 'Number'
    description "Min nodes for #{ asg_name }"
    default 1
  end

  parameters("#{_name}_auto_scaling_group_desired_capacity".to_sym) do
    type 'Number'
    description "Desired capacity for the the AutoScalingGroup"
    default 2
  end

  # Add a load balancer if one is specified
  if _config[:load_balancer_names]
    parameters("#{_name}_auto_scaling_group_load_balancer_names".to_sym) do
      type 'String'
      description 'Load balancer names to associate this AutoScalingGroup with'
      default _config[:load_balancer_names].join(",")
    end
  end

  resources(asg_name) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      launch_configuration_name _config[:launch_configuration_name]
      max_size _config[:max_size] || ref!("#{_name}_auto_scaling_group_max_size".to_sym)
      min_size _config[:min_size] || ref!("#{_name}_auto_scaling_group_max_size".to_sym)
      desired_capacity _config[:desired_capacity] || ref!("#{_name}_auto_scaling_group_desired_capacity".to_sym)
      load_balancer_names _config[:load_balancer_names] if _config[:load_balancer_names]
    end
    creation_policy do
      resource_signal do
        count 1
        timeout "PT10M"
      end
    end
  end

  outputs("#{_name}_auto_scaling_group_max_size".to_sym) do
    description "The max size for the #{ asg_name } AutoScalingGroup"
    value ref!("#{_name}_auto_scaling_group_max_size".to_sym)
  end

  outputs("#{_name}_auto_scaling_group_min_size".to_sym) do
    description "The min size for the #{ asg_name } AutoScalingGroup"
    value ref!("#{_name}_auto_scaling_group_max_size".to_sym)
  end

end
