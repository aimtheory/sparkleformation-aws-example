SparkleFormation.new('website').load(:base).overrides do

  set!('AWSTemplateFormatVersion', '2010-09-09')

  description 'Supercool Website'

  parameters.web_nodes do
    type 'Number'
    description 'Number of web nodes for ASG.'
    default 2
  end

  resources.security_group_website do
    type 'AWS::EC2::SecurityGroup'
    properties do
      group_description 'Enable SSH'
      security_group_ingress array!(
        -> {
          ip_protocol 'tcp'
          from_port 22
          to_port 22
          cidr_ip '0.0.0.0/0'
        }
      )
    end
  end

  resources.website_autoscale do
    type 'AWS::AutoScaling::AutoScalingGroup'
    properties do
      availability_zones({'Fn::GetAZs' => ''})
      launch_configuration_name ref!(:website_launch_config)
      min_size ref!(:web_nodes)
      max_size ref!(:web_nodes)
    end
  end

  resources.website_launch_config do
    type 'AWS::AutoScaling::LaunchConfiguration'
    properties do
      security_groups [ ref!(:security_group_website) ]
      key_name 'sparkleinfrakey'
      image_id 'ami-59a4a230'
      instance_type 'm3.medium'
    end
  end

  resources.website_elb do
    type 'AWS::ElasticLoadBalancing::LoadBalancer'
    properties do
      availability_zones._set('Fn::GetAZs', '')
      listeners _array(
        -> {
          load_balancer_port '80'
          protocol 'HTTP'
          instance_port '80'
          instance_protocol 'HTTP'
        }
      )
      health_check do
        target 'HTTP:80/'
        healthy_threshold '3'
        unhealthy_threshold '3'
        interval '10'
        timeout '8'
      end
    end
  end
end
