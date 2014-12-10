# Registry: nginx_install
# Description: A command to install nginx as defined in an
# AWS::AutoScalingGroup::LaunchConfiguration resource. This registry
# needs to be inserted into such a resource to work properly.
SparkleFormation::Registry.register(:nginx_install) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    config do
      commands('nginx_install') do
        command 'sudo apt-get install nginx -y && service nginx start'
        test 'test ! -d /etc/nginx'
      end
    end
  end
end
