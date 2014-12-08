# Registry: mysql_install
# Description: A command to install MySQL under Debian as defined in an
# AWS::AutoScalingGroup::LaunchConfiguration resource. This registry
# needs to be inserted into such a resource in order to work properly.
SparkleFormation::Registry.register(:mysql_install) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    config do
      commands('mysql_install') do
        command 'sudo apt-get install mysql_server -y'
        test 'test ! -d /etc/mysql'
      end
    end
  end
end
