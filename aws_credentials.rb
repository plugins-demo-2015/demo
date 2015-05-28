require 'yaml'
def get_aws_credentials()
  return YAML::load_file(File.join(File.dirname(__FILE__), "..", ".aws_secrets"))
end

def inject_aws_credentials(aws, override, amifield)
  aws_config = get_aws_credentials()
  aws.access_key_id = aws_config.fetch("access_key_id")
  aws.secret_access_key = aws_config.fetch("secret_access_key")
  aws.keypair_name = aws_config.fetch("keypair_name")
  name = aws_config.fetch("instance_name_prefix") + " docker-plugins-ami-builder"
  aws.tags = {
      'Name' => name
  }

  # this AMI is specific to the EAST 1 region - the keypair must also be in that region
  aws.ami = aws_config.fetch(amifield)#{}"ami-3cf8b154"
  aws.instance_type = aws_config.fetch("instance_type")#{}"c3.xlarge"
  aws.user_data = "#!/bin/bash\nsed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers"

  override.vm.box = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  override.ssh.username = "ubuntu"
  override.ssh.private_key_path = aws_config.fetch("keypair_path")
end