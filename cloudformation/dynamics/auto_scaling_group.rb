SparkleFormation.dynamic(:auto_scaling_group) do |_name, _config={}|
  resources("#{_name}_auto_scaling_group".to_sym) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    availability_zones._set('FN::GetAZs', '')
    launch_configuration_name _config[:launch_configuration_name]
    max_size _config[:max_size] || 2
    min_size _config[:min_size] || 1
  end
end
