# Dynamic: auto_scaling_group
# Description: Creates an AWS::AutoScaling::AutoScalingGroup resource
# _config inputs: 
#   :launch_configuration_name as ref!
#   :max_size as integer
#   :min_size as integer
#
# Outputs:
#    

SparkleFormation.dynamic(:auto_scaling_group) do |_name, _config={}|

  asg_name = "#{_name}_auto_scaling_group".to_sym 

  resources(asg_name) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      launch_configuration_name _config[:launch_configuration_name]
      max_size _config[:max_size] || 2
      min_size _config[:min_size] || 1
    end
  end

  outputs(asg_name.to_sym) do
    description "The name of the created #{ ref!(asg_name) } AutoScalingGroup resource"
    value asg_name
  end

  outputs("#{_name}_min_size".to_sym) do
    description 'The min size for the #{ ref!(asg_name) } AutoScalingGroup'
    value _config[:min_size]
  end

  outputs("#{_name}_max_size".to_sym) do
    description 'The max size for the #{ ref!(asg_name) } AutoScalingGroup'
    value _config[:max_size]
  end

end
