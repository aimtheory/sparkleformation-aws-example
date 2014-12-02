

SparkleFormation.new('db_app').load(:base).overrides do

  description 'Database application'

  # Setup reusable values
  app_protocol = 'TCP'
  app_port = 'HTTP'

  # Create the security group resources
  dynamic!(:security_group, 'db')
  dyanmic!(:security_group, 'app')

  # Create the security group ingress rules
  # This rule to allow access to the db sg from the app sg
  dynamic!(:security_group_ingress, 'db_app',
           :from_port => app_port,
           :to_port => app_port,
           :ip_protocol => app_protocol,
           :source_security_group => ref!(:app_security_group)
  )

  # This rulle to allow access to the app nodes from the elb (in the
  # app sg) or from other app nodes
  dynamic!(:security_group_ingress, 'app_app',
           :from_port => app_port,
           :to_port => app_port,
           :ip_protocol => app_protocol,
           :source_security_group => ref!(:app_security_group)
  )     

  # Create the load balancer resource
  dynamic!(:load_balancer, 'db_app',
           :balancer_http => app_port,
           :balancer_protocol => app_protocol,
           :instance_http => app_port,
           :instance_protocol => app_protocol
  )

  # Create the db asg
  dynamic!(:auto_scaling_group, 'db')

  # Create the app asg
  dynamic!(:auto_scaling_group, 'app')

end
