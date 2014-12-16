# Registry: mysql_install
# Description: A command to install MySQL under Debian as defined in an
# AWS::AutoScalingGroup::LaunchConfiguration resource. This registry
# needs to be inserted into such a resource in order to work properly.
SparkleFormation::Registry.register(:mysql_install) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    config do
      commands('mysql_install') do
        command 'debconf-set-selections <<< "mysql-server mysql-server/root_password password password1" && debconf-set-selections <<< "mysql-server mysql-server/root_password_again password password1" && apt-get -y install mysql-server && service mysql start'
        test 'test ! -d /etc/mysql'
      end
    end
  end
end
