SparkleFormation.new('db_app').load(:base).overrides do

  description 'Database application'

  # Setup reusable values
  app_protocol = 'tcp'
  app_port = '80'

  db_protocol = 'tcp'
  db_port = '3306'

  # Create the security group resources
  dynamic!(:security_group, 'db')
  dynamic!(:security_group, 'app')

  # Create the security group ingress rules
  # This rule to allow access to the db sg from the app sg
  dynamic!(:security_group_ingress, 'db_app',
           :from_port => db_port,
           :to_port => db_port,
           :ip_protocol => db_protocol,
           :group_name => ref!(:db_security_group),
           :source_security_group_name => ref!(:app_security_group)
  )

  # This rulle to allow access to the app nodes from the elb (in the
  # app sg) or from other app nodes
  dynamic!(:security_group_ingress, 'app_app',
           :from_port => app_port,
           :to_port => app_port,
           :ip_protocol => app_protocol,
           :group_name => ref!(:app_security_group),
           :source_security_group_name => ref!(:app_security_group)
  )     

  dynamic!(:launch_configuration, 'db',
           :image_id => 'ami-59a4a230',
           :instance_type => 'm1.small',
           :key_name => 'sparkleinfrakey',
           :security_groups => [ ref!(:db_security_group) ]
  )

  # Install MySQL in db AutoScalingGroup
  resources(:db_launch_configuration) do
    registry!(:mysql_install)
  end

  # Create the AutoScaling LaunchConfiguration for the app asg
  dynamic!(:launch_configuration, 'app',
           :image_id => 'ami-59a4a230',
           :instance_type => 'm1.small',
           :key_name => 'sparkleinfrakey',
           :security_groups => [ ref!(:app_security_group) ]
  )

  # Instal nginx in app AutoScalingGroup
  resources(:app_launch_configuration) do
    registry!(:nginx_install)
  end
 
  # Create the db asg
  dynamic!(:auto_scaling_group, 'db',
           :launch_configuration_name => ref!(:app_launch_configuration),
           :max_size => 3,
           :min_size => 2
  )

  # Create the app asg
  dynamic!(:auto_scaling_group, 'app',
           :launch_configuration_name => ref!(:db_launch_configuration),
           :max_size => 3,
           :min_size => 2,
           :load_balancer_names => [ 'sparkle-doc-elb' ]
  )

end
