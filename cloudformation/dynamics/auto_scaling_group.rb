# Dynamic: auto_scaling_group
# Description: Creates an AWS::AutoScaling::AutoScalingGroup resource
# Config: 
#   :launch_configuration_name as ref!
#   :size as number
#
# Parameters:
#   #{asg_name}_size
#
# Outputs:
#   #{asg_name}_size

SparkleFormation.dynamic(:auto_scaling_group) do |_name, _config={}|

  asg_name = "#{_name}_auto_scaling_group"

  parameters do

    set!("#{asg_name}_size".to_sym) do
      type 'Number'
      description "Number of desired nodes for the AutoScalingGroup resource"
      default _config[:size]
    end

    # If required, add a load balancer using --apply-stack and output from a
    # load_balancer stack
     if _config[:load_balance] == true then 
       set!("#{asg_name}_load_balancer_resource_name".to_sym) do
         type 'String'
         description 'The AWS::ElasticLoadBalancing::LoadBalancer resource name to associate this AutoScalingGroup with'
         default 'LOAD_BALANCER_NAME_HERE'
       end
     end

  end

  resources("#{asg_name}_launch_wait_condition".to_sym) do
    type 'AWS::CloudFormation::WaitCondition'
    depends_on _process_key(asg_name.to_sym)
    properties do
      count ref!("#{asg_name}_size".to_sym)
      handle ref!("#{_name}_launch_wait_handle".to_sym)
      timeout '1800'
    end
  end

  resources(asg_name.to_sym) do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      launch_configuration_name _config[:launch_configuration_name]
      max_size ref!("#{asg_name}_size".to_sym)
      min_size ref!("#{asg_name}_size".to_sym)
      desired_capacity ref!("#{asg_name}_size".to_sym)
      if _config[:load_balance] == true then
        load_balancer_names [ ref!("#{asg_name}_load_balancer_resource_name".to_sym) ]
      end
    end
  end

  outputs do

    set!("#{asg_name}_size".to_sym) do
      description "The desired size of the AutoScalingGroup"
      value ref!("#{asg_name}_size".to_sym)
    end

    if _config[:load_balance] == true then
      set!("#{asg_name}_load_balancer_resource_name".to_sym) do
        description 'The LoadBalancer resource name to associate with the AUtoScalingGroup'
        value ref!("#{asg_name}_load_balancer_resource_name".to_sym)
      end
    end

  end

end
