SparkleFormation.new('db_app_load_balancer').load(:base).overrides do

  description 'Database application load balancer'

  # Setup reusable values
  app_protocol = 'tcp'
  app_port = '80'
 
  # Create the load balancer resource
  dynamic!(:load_balancer, 'db_app',
           :protocol => app_protocol,
           :instance_port => app_port,
           :instance_protocol => app_protocol
  )

end
