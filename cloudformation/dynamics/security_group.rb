# Dynamic: security_group
# Description: Creates an AWS::EC2::SecurityGroup resource
# Config:
#   none
#
# Outputs:
#   #{_name}_security_group - The created name of the sec group

SparkleFormation.dynamic(:security_group) do |_name, _config={}|

  sg_name = "#{_name}_security_group".to_sym

  # Create the SecurityGroup resource
  resources(sg_name) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      group_description "Security group for #{_name}"
    end
  end

  # Create the SSH ingress rule for the security group
  resources("#{_name}_security_group_ingress".to_sym) do
    type 'AWS::EC2::SecurityGroupIngress'
    properties do
      from_port 22
      to_port 22
      ip_protocol 'tcp'
      group_name ref!(sg_name)
      cidr_ip '0.0.0.0/0'
    end
  end

end
