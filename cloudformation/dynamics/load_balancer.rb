# Dynamic: load_balancer
# Description: Creates an AWS::ElasticLoadBalancing::LoadBalancer
# resource
# Config:
#   :security_groups as array
#   :port as number
#   :protocol as string
#   :instance_port as number 
#   :instance_protocol as string
#   :target as string
#   :healthy_threshold as number
#   :unhealthy_threshold as number
#   :interval as number
#   :timeout as number
#
# Parameters:   
#   #{_name}_load_balancer_security_groups as comma delimited list
#   #{_name}_load_balancer_port as number
#   #{_name}_load_balancer_protocol as string
#   #{_name}_load_balancer_instance_port as number
#   #{_name}_load_balancer_instance_protocol as string
#   #{_name}_load_balancer_target as string
#   #{_name}_load_balancer_healthy_threshold as number
#   #{_name}_load_balancer_unhealthy_threshold as number
#   #{_name}_load_balancer_interval as number
#   #{_name}_load_balancer_timeout as number
#
# Outputs: (as ref!s to the parameters' user defined values)   
#   #{_name}_load_balancer_security_groups as comma delimited list
#   #{_name}_load_balancer_port as number
#   #{_name}_load_balancer_protocol as string
#   #{_name}_load_balancer_instance_port as number
#   #{_name}_load_balancer_instance_protocol as string
#   #{_name}_load_balancer_target as string
#   #{_name}_load_balancer_healthy_threshold as number
#   #{_name}_load_balancer_unhealthy_threshold as number
#   #{_name}_load_balancer_interval as number
#   #{_name}_load_balancer_timeout as number

SparkleFormation.dynamic(:load_balancer) do |_name, _config={}|

  lb_name = "#{_name}_load_balancer".to_sym

  parameters("#{_name}_load_balancer_security_groups".to_sym) do
    type 'CommaDelimitedList'
    description 'List of SecurityGroups for the LoadBalancer resource'
    default _config[:security_groups] || 'default'
  end

  parameters("#{_name}_load_balancer_port".to_sym) do
    type 'Number'
    description 'Listening port for the LoadBalancer resource'
    default _config[:port] || '80'
  end

  parameters("#{_name}_load_balancer_protocol".to_sym) do
    type 'String'
    description 'Protocol for the listener of the LoadBalancer resource'
    default _config[:protocol] || 'tcp'
  end

  parameters("#{_name}_load_balancer_instance_port".to_sym) do
    type 'Number'
    description 'InstancePort for the listener of the LoadBalancer resource'
    default _config[:instance_port] || '80'
  end

  parameters("#{_name}_load_balancer_instance_protocol".to_sym) do
    type 'String'
    description 'InstanceProtocol for the listener of the LoadBalancer resource'
    default _config[:instance_protocol] || 'tcp'
  end

  parameters("#{_name}_load_balancer_target".to_sym) do
    type 'String'
    description 'HealthCheck Target for the LoadBalancer resource'
    default _config[:target] || 'HTTP:80/'
  end

  parameters("#{_name}_load_balancer_healthy_threshold".to_sym) do
    type 'Number'
    description 'HealthCheck HealthyThreshold for the LoadBalancer resource'
    default _config[:healthy_threshold] || '3'
  end

  parameters("#{_name}_load_balancer_unhealthy_threshold".to_sym) do
    type 'Number'
    description 'HealthCheck UnHealthyThreshold for the LoadBalancer resource'
    default _config[:unhealthy_threshold] || '3'
  end

  parameters("#{_name}_load_balancer_interval".to_sym) do
    type 'Number'
    description 'HealthCheck Interval for the LoadBalancer resource'
    default _config[:interval] || '10'
  end

  parameters("#{_name}_load_balancer_timeout".to_sym) do
    type 'Number'
    description 'HealthCheck Timeout for the LoadBalancer resource'
    default _config[:timeout] || '8'
  end

  resources(lb_name) do
    type 'AWS::ElasticLoadBalancing::LoadBalancer'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      listeners _array(
        -> {
          load_balancer_port _config[:port] || ref!("#{_name}_load_balancer_port".to_sym)
          protocol _config[:protocol] || ref!("#{_name}_load_balancer_protocol".to_sym)
          instance_port _config[:instance_port] || ref!("#{_name}_load_balancer_instance_port".to_sym)
          instance_protocol _config[:instance_protocol] || ref!("#{_name}_load_balancer_instance_protocol".to_sym)
        }
      )
      health_check do
        target _config[:target] || ref!("#{_name}_load_balancer_target".to_sym)
        healthy_threshold _config[:healthy_threshold] || ref!("#{_name}_load_balancer_healthy_threshold".to_sym)
        unhealthy_threshold _config[:unhealthy_threshold] || ref!("#{_name}_load_balancer_unhealthy_threshold".to_sym)
        interval _config[:interval] || ref!("#{_name}_load_balancer_interval".to_sym)
        timeout _config[:timeout] || ref!("#{_name}_load_balancer_timeout".to_sym)
      end
    end
  end

  outputs("#{_name}_load_balancer_port".to_sym) do
    description 'Listening port for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_port".to_sym)
  end

  outputs("#{_name}_load_balancer_protocol".to_sym) do
    description 'Protocal for the listener of the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_protocol".to_sym)
  end

  outputs("#{_name}_load_balancer_instance_port".to_sym) do
    description 'InstancePort for the listener of the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_instance_port".to_sym)
  end

  outputs("#{_name}_load_balancer_instance_protocol".to_sym) do
    description 'InstanceProtocol for the listener of the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_instance_protocol".to_sym)
  end

  outputs("#{_name}_load_balancer_target".to_sym) do
    description 'HealthCheck Target for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_target".to_sym)
  end

  outputs("#{_name}_load_balancer_healthy_threshold".to_sym) do
    description 'HealthCheck HealthyThreshold for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_healthy_threshold".to_sym)
  end

  outputs("#{_name}_load_balancer_unhealthy_threshold".to_sym) do
    description 'HealthCheck UnHealthyThreshold for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_unhealthy_threshold".to_sym)
  end

  outputs("#{_name}_load_balancer_interval".to_sym) do
    description 'HealthCheck Interval for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_interval".to_sym)
  end

  outputs("#{_name}_load_balancer_timeout".to_sym) do
    description 'HealthCheck Timeout for the LoadBalancer resource'
    value ref!("#{_name}_load_balancer_timeout".to_sym)
  end

end
