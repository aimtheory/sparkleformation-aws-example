# Registry: mysql_install
# Description: Some commands to install and configure MySQL under Debian as defined in an
# AWS::AutoScalingGroup::LaunchConfiguration resource. This registry
# needs to be inserted into such a resource in order to work properly.
SparkleFormation::Registry.register(:mysql_install) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    config do
      commands('mysql_install') do
        command 'DEBIAN_FRONTEND=noninteractive apt-get -q -y install mysql-server'
        test 'test ! -d /etc/mysql'
      end
      commands('mysql_listen_address') do
        command 'sed -i s/127.0.0.1/0.0.0.0/g /etc/mysql/my.cnf && service mysql restart'
        test 'test -n "`cat /etc/mysql/my.cnf  | grep 127.0.0.1`"'
      end
    end
  end
end
