packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  profile = "default"
  ami_name      = "app-symfony-packer-aws-{{timestamp}}"
  instance_type = "t3.small"
  region        = "eu-west-3"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
build {
  sources = ["sources.amazon-ebs.ubuntu"]

    provisioner "shell" {
      inline = [
        "set -e #aborta el comando en caso de error",
        "sudo timedatectl set-timezone Europe/Madrid"
      ]
    }

    provisioner "ansible" {    
      playbook_file = "provisioners/ansible/instalar_aplicacion.yml"
      groups = ["curso"]
      extra_arguments = [
          "--extra-vars",
          "mysql_root_password=1q2w3e4r5t6y admin_user=www-data"
      ]
    }
}
