# Dynamic: security_group_ingress
# Description: Creates an AWS::EC2::SecurityGroupIngress rule resource
# Config:
#   :from_port as integer
#   :to_port as integer
#   :ip_protocol as string
#   :group_name as string
#   :source_security_group_name as string
#
# Parameters:
#   #{_name}_security_group_ingress_from_port as integer
#   #{_name}_security_group_ingress_to_port as integer
#   #{_name}_security_group_ingress_ip_protocol as string
#   #{_name}_security_group_ingress_group_name as string
#   #{_name}_security_group_ingress_source_security_group_name as string
#
# Outputs: (as ref!s to the parameters' user defined values)
#   #{_name}_security_group_ingress_from_port as integer
#   #{_name}_security_group_ingress_to_port as integer
#   #{_name}_security_group_ingress_ip_protocol as string
#   #{_name}_security_group_ingress_group_name as string
#   #{_name}_security_group_ingress_source_security_group_name as
# string
SparkleFormation.dynamic(:security_group_ingress) do |_name, _config={}|
  
  parameters("#{_name}_security_group_ingress_from_port".to_sym) do
    type 'Integer'
    description "The FromPort for the #{_name} SecurityGroupIngress rule"
    default _config[:from_port] || '22'
  end

  parameters("#{_name}_security_group_ingress_to_port".to_sym) do
    type 'Integer'
    description "The ToPort for the #{_name} SecurityGroupIngress rule"
    default _config[:to_port] || '22'
  end

  parameters("#{_name}_security_group_ingress_ip_protocol".to_sym) do
    type 'String'
    description "The IpProtocol for the #{_name} SecurityGroupIngress rule"
    default _config[:ip_protocol] || 'tcp'
  end

  parameters("#{_name}_security_group_ingress_group_name".to_sym) do
    type 'String'
    description "The GroupName for the #{_name} SecurityGroupIngress rule"
    default _config[:group_name] || 'default'
  end

  parameters("#{_name}_security_group_ingress_source_security_group_name".to_sym) do
    type 'String'
    description "The SourceSecurityGroupName for the #{_name} SecurityGroupIngress rule"
    default _config[:source_security_group_name] || 'default'
  end

  resources("#{_name}_security_group_ingress".to_sym) do
    type 'AWS::EC2::SecurityGroupIngress'
    properties do
      from_port ref!("#{_name}_security_group_ingress_from_port".to_sym)
      to_port ref!("#{_name}_security_group_ingress_to_port".to_sym)
      ip_protocol ref!("#{_name}_security_group_ingress_ip_protocol".to_sym)
      group_name ref!("#{_name}_security_group_ingress_group_name".to_sym)
      source_security_group_name ref!("#{_name}_security_group_ingress_source_security_group_name".to_sym)
    end
  end

  outputs("#{_name}_security_group_ingress_from_port".to_sym) do
    description "The FromPort for the #{_name} SecurityGroupIngress rule"
    value ref!("#{_name}_security_group_ingress_from_port".to_sym)
  end

  outputs("#{_name}_security_group_ingress_to_port".to_sym) do
    description "The ToPort for the #{_name} SecurityGroupIngress rule"
    value ref!("#{_name}_security_group_ingress_to_port".to_sym)
  end

  outputs("#{_name}_security_group_ingress_ip_protocol".to_sym) do
    description "The IpProtocol for the #{_name} SecurityGroupIngress rule"
    value ref!("#{_name}_security_group_ingress_ip_protocol".to_sym)
  end

  outputs("#{_name}_security_group_ingress_group_name".to_sym) do
    description "The GroupName for the #{_name} SecurityGroupIngress rule"
    value ref!("#{_name}_security_group_ingress_group_name".to_sym)
  end

  outputs("#{_name}_security_group_ingress_source_security_group_name".to_sym) do
    description "The SourceSecurityGroupName for the #{_name} SecurityGroupIngress rule"
    value ref!("#{_name}_security_group_ingress_source_security_group_name".to_sym)
  end

end
