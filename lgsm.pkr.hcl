locals { timestamp = formatdate("YYYYMMDD", timestamp()) }

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "linode_region" {
  type    = string
  default = "us-east"
}

variable "linode_token" {
  type    = string
  default = ""
}

variable "game" {
  type = string
}

source "amazon-ebs" "aws" {
  # Name the AMI according to best practices
  # https://www.cloudconformity.com/knowledge-base/aws/EC2/ami-naming-conventions.html
  ami_name = "ami-${var.aws_region}-p-${var.game}-${local.timestamp}"
  # If you use an underpowered EC2, the game install can hang for a few minutes
  # Try to use at least a c5a.large, but it could theoretically run on a t2.nano!
  instance_type = "c5a.large"
  region        = "${var.aws_region}"
  # Pull the most recent Ubuntu 20.04 image for compatability across different builders
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  # Ark is so incredibly beefy that it doesn't fit within 8 GB
  # You might be able to squeeze it into 15 GB?
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = var.game == "arkserver" ? 20 : 8
  }

  ssh_username = "ubuntu"
  tags = {
    OS            = "Ubuntu 20.04"
    Name          = "${var.game}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Created_On    = "${local.timestamp}"
    Region        = "${var.aws_region}"
  }
}

source "linode" "linode" {
  linode_token  = "${var.linode_token}"
  image         = "linode/ubuntu20.04"
  region        = "${var.linode_region}"
  instance_type = "g6-standard-1"
  ssh_username  = "root"
  image_label   = "private-image-${var.linode_region}-p-${var.game}-${local.timestamp}"
}

source "docker" "docker" {
  image  = "ubuntu:20.04"
  commit = true
  changes = [
    "USER ubuntu",
    "LABEL game=${var.game}"
  ]
}

build {
  sources = ["source.amazon-ebs.aws"]

  # Give time for the SSH agent to `wake up`
  provisioner "shell" {
    inline = [
      "sleep 10"
    ]
  }

  # Force the commands to run as root
  provisioner "shell" {
    execute_command = "sudo -u root /bin/bash -c '{{.Path}}'"
    script          = "./provision_scripts/install_steamcmd.sh"
  }

  # nvm doesn't require root
  provisioner "shell" {
    script = "./provision_scripts/install_nodejs.sh"
  }

  provisioner "shell" {
    execute_command = "sudo -u root /bin/bash -c '{{.Path}}'"
    script          = "./provision_scripts/${var.game}.sh"
  }

  # GAME_lgsm.sh can't be run as root!
  provisioner "shell" {
    script = "./provision_scripts/${var.game}_lgsm.sh"
  }

}

build {
  # Linode is closer to Docker than AWS lol
  sources = ["source.docker.docker", "source.linode.linode"]

  # Ubuntu in a Docker container does not come with sudo installed
  # Linode needs an ubuntu user
  provisioner "shell" {
    script = "./provision_scripts/install_sudo.sh"
  }

  provisioner "shell" {
    script = "./provision_scripts/install_steamcmd.sh"
  }

  # Install nvm using user ubuntu
  provisioner "shell" {
    execute_command = "su - ubuntu -c '{{.Path}}'"
    script          = "./provision_scripts/install_nodejs.sh"
  }

  provisioner "shell" {
    script = "./provision_scripts/${var.game}.sh"
  }

  # Docker + Linode is a pain - it defaults to running as root even if not told to
  # We need to run the GAME_lgsm.sh script as ubuntu
  provisioner "shell" {
    execute_command = "su - ubuntu -c '{{.Path}}'"
    script          = "./provision_scripts/${var.game}_lgsm.sh"
  }

  # Tag the image so we know what it is
  post-processor "docker-tag" {
    only       = ["docker.docker"]
    repository = "${var.game}"
    tag        = ["latest"]
  }
}