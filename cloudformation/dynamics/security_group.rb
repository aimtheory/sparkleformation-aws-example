# Dynamic: security_group
# Description: Creates an AWS::EC2::SecurityGroup resource
# Config:
#   none
#
# Outputs:
#   #{_name}_security_group - The created name of the sec group

SparkleFormation.dynamic(:security_group) do |_name, _config={}|

  sg_name = "#{_name}_security_group"

  resources(sg_name.to_sym) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      group_description "Security group for #{_name}"
    end
  end

  outputs(sg_name.to_sym) do
    description 'Created security group'
    value ref!("#{_name}_security_group".to_sym)
  end

  outputs("#{_name}_security_group_ingress".to_sym) do
    description 'List of security group ingress rules for the security group'
    value _config[:security_group_ingress]
  end

end

