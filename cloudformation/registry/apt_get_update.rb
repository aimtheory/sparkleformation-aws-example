SparkleFormation::Registry.register(:apt_get_update) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    config do
      commands('01_apt_get_update') do
        command 'sudo apt-get update'
        test 'test -z ` HISTCONTROL=ignorespace history | grep "apt-get update"`'
      end
      commands('02_apt_get_upgrade') do
        command 'sudo apt-get upgrade -y'
        test 'test -z ` HISTCONTROL=ignorespace history | grep "apt-get upgrade"`'
      end
    end
  end
end
