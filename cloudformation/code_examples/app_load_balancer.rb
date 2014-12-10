SparkleFormation.new('app_load_balancer').load(:base).overrides do

  description 'Database application load balancer'
 
  # Create the load balancer resource and use defaults
  dynamic!(:load_balancer, 'app')

end
