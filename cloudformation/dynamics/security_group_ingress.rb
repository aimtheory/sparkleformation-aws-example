# Dynamic: security_group_ingress
# Description: Creates an AWS::EC2::SecurityGroupIngress rule resource
# Config:
#   :port as number
#   :ip_protocol as string
#   :group_name as string
#   :source_security_group_name as string
#
# Parameters:
#   #{sgi_name}_port as number
#   #{sgi_name}_ip_protocol as string
#   #{sgi_name}_source_security_group_name as string
#
# Outputs: (as ref!s to the parameters' user defined values)
#   port as number
#   ip_protocol as string
#   source_security_group_name as string
#
SparkleFormation.dynamic(:security_group_ingress) do |_name, _config={}|

  sgi_name = "#{_name}_security_group_ingress"
 
  parameters do

    set!("#{sgi_name}_port".to_sym) do
      type 'Number'
      description "The port number for the SecurityGroupIngress rule"
      default _config[:port] || '22'
    end

    set!("#{sgi_name}_ip_protocol".to_sym) do
      type 'String'
      description "The IpProtocol for the SecurityGroupIngress rule"
      default _config[:ip_protocol] || 'tcp'
    end

  end

  resources("#{sgi_name}".to_sym) do
    type 'AWS::EC2::SecurityGroupIngress'
    properties do
      from_port ref!("#{sgi_name}_port".to_sym)
      to_port ref!("#{sgi_name}_port".to_sym)
      ip_protocol ref!("#{sgi_name}_ip_protocol".to_sym)
      group_name _config[:group_name]
      if _config[:cidr_ip] then
        cidr_ip _config[:cidr_ip]
      else
        source_security_group_name _config[:source_group_name]
      end
    end
  end

  outputs do
    set!("#{sgi_name}_port".to_sym) do
      description "The Port number for the SecurityGroupIngress rule"
      value ref!("#{sgi_name}_port".to_sym)
    end

    set!("#{sgi_name}_ip_protocol".to_sym) do
      description "The IpProtocol for the SecurityGroupIngress rule"
      value ref!("#{sgi_name}_ip_protocol".to_sym)
    end

  end

end
