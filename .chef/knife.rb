

knife[:aws_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']

[:cloudformation, :options].inject(knife){ |m,k| m[k] ||= Mash.new }
knife[:cloudformation][:options][:disable_rollback] = ENV['AWS_CFN_DISABLE_ROLLBACK'].to_s.downcase == 'true'
knife[:cloudformation][:options][:capabilities] = ['CAPABILITY_IAM']
knife[:cloudformation][:processing] = true
knife[:cloudformation][:credentials] = {
  :aws_access_key_id => knife[:aws_access_key_id],
  :aws_secret_access_key => knife[:aws_secret_access_key]
}
