# Dynamic: auto_scaling_group
# Description: Creates an AWS::AutoScaling::AutoScalingGroup resource
# Parameters:
#   #{_name}_auto_scaling_group_max_size
#   #{_name}_auto_scaling_group_min_size
#
# Config: 
#   :launch_configuration_name as ref!
#   :max_size as integer
#   :min_size as integer
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

  resources(asg_name) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      launch_configuration_name _config[:launch_configuration_name]
      max_size _config[:max_size] || ref!("#{_name}_auto_scaling_group_max_size".to_sym)
      min_size _config[:min_size] || ref!("#{_name}_auto_scaling_group_max_size".to_sym)
    end
  end

  outputs("#{_name}_auto_scaling_group_max_size".to_sym) do
    description "The max size for the #{ asg_name } AutoScalingGroup"
    value _config[:max_size]
  end

  outputs("#{_name}_auto_scaling_group_min_size".to_sym) do
    description "The min size for the #{ asg_name } AutoScalingGroup"
    value _config[:min_size]
  end

end
