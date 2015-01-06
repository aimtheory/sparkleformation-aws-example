SparkleFormation.new('db_app').load(:base).overrides do

  description 'Database application'

  # Setup reusable values
  app_protocol = 'tcp'
  app_port = '80'

  db_protocol = 'tcp'
  db_port = '3306'

  # Create the security groups
  dynamic!(:security_group, 'db')
  dynamic!(:security_group, 'app')

  # Long lasting load balancer for app asg is created in another stack

  # Create ingress rules
  # This rule to allow access to the db sg from the app sg.
  dynamic!(:security_group_ingress, 'db_app',
           :port => db_port,
           :ip_protocol => db_protocol,
           :group_name => ref!(:db_security_group),
           :source_group_name => ref!(:app_security_group)
  )

  # This rule to allow access to the app nodes from the public, the
  # elb or from other app nodes.
  dynamic!(:security_group_ingress, 'app_app',
           :port => app_port,
           :ip_protocol => app_protocol,
           :group_name => ref!(:app_security_group),
           :cidr_ip => '0.0.0.0/0'
  )

  # Set ASG LaunchConfigurations to proper security groups with
  # outputs from security groups stack
  # Create the AutoScaling LaunchConfiguration for the db asg
  dynamic!(:launch_configuration, 'db',
           :image_id => 'ami-59a4a230',
           :instance_type => 'm1.small',
           :security_group => ref!(:db_security_group)
  )

  # Install MySQL in db AutoScalingGroup
  resources(:db_launch_configuration) do
    registry!(:apt_get_update)
    registry!(:mysql_install)
  end

  # Create the AutoScaling LaunchConfiguration for the app asg
  dynamic!(:launch_configuration, 'app',
           :image_id => 'ami-59a4a230',
           :instance_type => 'm1.small',
           :security_group => ref!(:app_security_group)
  )

  # Install nginx in app AutoScalingGroup
  resources(:app_launch_configuration) do
    registry!(:apt_get_update)
    registry!(:nginx_install)
  end
 
  # Create the db asg
  dynamic!(:auto_scaling_group, 'db',
           :launch_configuration_name => ref!(:db_launch_configuration),
           :size => 2
  )

  # Create the app asg and load balance it
  dynamic!(:auto_scaling_group, 'app',
           :launch_configuration_name => ref!(:app_launch_configuration),
           :size => 2,
           :load_balance => true
  )

end
