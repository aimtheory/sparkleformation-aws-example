SparkleFormation.new('db_app_load_balancer').load(:base).overrides do

  description 'Database application load balancer'

  # Setup reusable values
  app_protocol = 'tcp'
  app_port = '80'
 
  # Create the load balancer resource
  dynamic!(:load_balancer, 'db_app',
           :balancer_http => app_port,
           :balancer_protocol => app_protocol,
           :instance_http => app_port,
           :instance_protocol => app_protocol,
           :security_groups => 'AppSecurityGroup'
  )

end
