# Dynamic: load_balancer
# Description: Creates an AWS::ElasticLoadBalancing::LoadBalancer
# resource
# Config:
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
#   #{lb_name}_port as number
#   #{lb_name}_protocol as string
#   #{lb_name}_instance_port as number
#   #{lb_name}_instance_protocol as string
#   #{lb_name}_target as string
#   #{lb_name}_healthy_threshold as number
#   #{lb_name}_unhealthy_threshold as number
#   #{lb_name}_interval as number
#   #{lb_name}_timeout as number
#
# Outputs: (as ref!s to the parameters' user defined values)   
#   port as number
#   protocol as string
#   instance_port as number
#   instance_protocol as string
#   target as string
#   healthy_threshold as number
#   unhealthy_threshold as number
#   interval as number
#   timeout as number
#   name as string

SparkleFormation.dynamic(:load_balancer) do |_name, _config={}|

  lb_name = "#{_name}_load_balancer"

  parameters do

    set!("#{lb_name}_port".to_sym) do
      type 'Number'
      description 'Listening port for the LoadBalancer resource'
      default _config[:port] || '80'
    end

    set!("#{lb_name}_protocol".to_sym) do
      type 'String'
      description 'Protocol for the listener of the LoadBalancer resource'
      default _config[:protocol] || 'tcp'
    end

    set!("#{lb_name}_instance_port".to_sym) do
      type 'Number'
      description 'InstancePort for the listener of the LoadBalancer resource'
      default _config[:instance_port] || '80'
    end

    set!("#{lb_name}_instance_protocol".to_sym) do
      type 'String'
      description 'InstanceProtocol for the listener of the LoadBalancer resource'
      default _config[:instance_protocol] || 'tcp'
    end

    set!("#{lb_name}_target".to_sym) do
      type 'String'
      description 'HealthCheck Target for the LoadBalancer resource'
      default _config[:target] || 'HTTP:80/'
    end

    set!("#{lb_name}_healthy_threshold".to_sym) do
      type 'Number'
      description 'HealthCheck HealthyThreshold for the LoadBalancer resource'
      default _config[:healthy_threshold] || '2'
    end

    set!("#{lb_name}_unhealthy_threshold".to_sym) do
      type 'Number'
      description 'HealthCheck UnHealthyThreshold for the LoadBalancer resource'
      default _config[:unhealthy_threshold] || '2'
    end

    set!("#{lb_name}_interval".to_sym) do
      type 'Number'
      description 'HealthCheck Interval for the LoadBalancer resource'
      default _config[:interval] || '10'
    end

    set!("#{lb_name}_timeout".to_sym) do
      type 'Number'
      description 'HealthCheck Timeout for the LoadBalancer resource'
      default _config[:timeout] || '8'
    end

  end

  resources(lb_name.to_sym) do
    type 'AWS::ElasticLoadBalancing::LoadBalancer'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      listeners _array(
        -> {
          load_balancer_port _config[:port] || ref!("#{lb_name}_port".to_sym)
          protocol _config[:protocol] || ref!("#{lb_name}_protocol".to_sym)
          instance_port _config[:instance_port] || ref!("#{lb_name}_instance_port".to_sym)
          instance_protocol _config[:instance_protocol] || ref!("#{lb_name}_instance_protocol".to_sym)
        }
      )
      health_check do
        target _config[:target] || ref!("#{lb_name}_target".to_sym)
        healthy_threshold _config[:healthy_threshold] || ref!("#{lb_name}_healthy_threshold".to_sym)
        unhealthy_threshold _config[:unhealthy_threshold] || ref!("#{lb_name}_unhealthy_threshold".to_sym)
        interval _config[:interval] || ref!("#{lb_name}_interval".to_sym)
        timeout _config[:timeout] || ref!("#{lb_name}_timeout".to_sym)
      end
    end
  end

  outputs do
    set!("#{_name}_auto_scaling_group_load_balancer_resource_name".to_sym) do
      description 'Name of the LoadBalancer resource'
      value ref!(lb_name.to_sym)
    end

    port do
      description 'Listening port for the LoadBalancer resource'
      value ref!("#{lb_name}_port".to_sym)
    end

    protocol do
      description 'Protocal for the listener of the LoadBalancer resource'
      value ref!("#{lb_name}_protocol".to_sym)
    end

    instance_port do
      description 'InstancePort for the listener of the LoadBalancer resource'
      value ref!("#{lb_name}_instance_port".to_sym)
    end

    instance_protocol do
      description 'InstanceProtocol for the listener of the LoadBalancer resource'
      value ref!("#{lb_name}_instance_protocol".to_sym)
    end

    target do
      description 'HealthCheck Target for the LoadBalancer resource'
      value ref!("#{lb_name}_target".to_sym)
    end

    healthy_threshold do
      description 'HealthCheck HealthyThreshold for the LoadBalancer resource'
      value ref!("#{lb_name}_healthy_threshold".to_sym)
    end

    unhealthy_threshold do
      description 'HealthCheck UnHealthyThreshold for the LoadBalancer resource'
      value ref!("#{lb_name}_unhealthy_threshold".to_sym)
    end

    interval do
      description 'HealthCheck Interval for the LoadBalancer resource'
      value ref!("#{lb_name}_interval".to_sym)
    end

    timeout do
      description 'HealthCheck Timeout for the LoadBalancer resource'
      value ref!("#{lb_name}_timeout".to_sym)
    end

  end

end
