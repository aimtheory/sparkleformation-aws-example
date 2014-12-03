SparkleFormation.dynamic(:security_group_ingress) do |_name, _config={}|
  resources("#{_name}_security_group_ingress".to_sym) do
    type 'AWS::EC2::SecurityGroupIngress'
    from_port _config[:from_port]
    to_port _config[:to_port]
    ip_protocol _config[:ip_protocol]
    group_name _config[:group_name]
    source_security_group_name _config[:source_security_group_name]
  end
end
