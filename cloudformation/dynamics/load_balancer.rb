# Dynamic: load_balancer
# Description: Creates an AWS::ElasticLoadBalancing::LoadBalancer
# resource
# Inputs: _config[:security_groups] as array
#         _config[:load_balancer_port] as integer
#         _config[:protocol] as string
#         _config[:instance_port] as integer
#         _config[:instance_protocol] as string
#         _config[:target] as string
#         _config[:healthy_threshold] as integer
#         _config[:unhealthy_threshold] as integer
#         _config[:interval] as integer
#         _config[:timeout] as integer

SparkleFormation.dynamic(:load_balancer) do |_name, _config={}|
    resources("#{_name}_load_balancer".to_sym) do
      type 'AWS::ElasticLoadBalancing::LoadBalancer'
      properties do
        availability_zones._set('Fn::GetAZs', '')
        security_groups _config[:security_groups] || [] 
        listeners _array(
          -> {
            load_balancer_port _config[:load_balancer_port] || '80'
            protocol _config[:protocol] || 'HTTP'
            instance_port _config[:instance_port] || '80'
            instance_protocol _config[:instance_protocol] || 'HTTP'
          }
        )
        health_check do
          target _config[:target] || 'HTTP:80/'
          healthy_threshold _config[:healthy_threshold] || '3'
          unhealthy_threshold _config[:unhealthy_threshold] || '3'
          interval _config[:interval] || '10'
          timeout _config[:timeout] || '8'
        end
      end
  end
end
