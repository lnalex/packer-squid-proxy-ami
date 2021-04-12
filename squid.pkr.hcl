# If you don't set a default, then you will need to provide the variable
# at run time using the command line, or set it in the environment. For more
# information about the various options for setting variables, see the template
# [reference documentation](https://www.packer.io/docs/templates)
variable "ami_name" {
  type    = string
  default = "squid-proxy-custom"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "base" {

  ami_name      = "squid proxy ${local.timestamp}"
  instance_type = "t3a.micro"
  region        = "ap-southeast-2"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.base"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update -y",
      "sudo apt-get dist-upgrade -y",
      "sudo apt-get install -y squid",
    ]
  }

  provisioner "file" {
    source = "files/squid-min.conf"
    destination = "/tmp/squid.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/squid.conf /etc/squid/squid.conf"
    ]
  }
}