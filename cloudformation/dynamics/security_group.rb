SparkleFormation.dynamic(:security_group) do |_name, _config={}|
  resources("#{_name}_security_group".to_sym) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      group_description "Security group for #{_name}"
      security_group_ingress _config[:security_group_ingress] || []
    end
  end
end
