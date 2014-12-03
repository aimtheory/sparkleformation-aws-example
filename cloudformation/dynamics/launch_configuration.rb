SparkleFormation.dynamic(:launch_configuration) do |_name, _config={}|
  resources("#{_name}_launch_configuration".to_sym) do
    type 'AWS::AutoScaling::LaunchConfiguration'
    image_id _config[:image_id]
    instance_type _config[:instance_type]
    key_name _config[:key_name]
    security_groups _config[:security_groups] || []
  end
end
