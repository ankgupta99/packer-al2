packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
 
    ami_name = "packer-ami-maf-hcl"
    instance_type        = "t2.micro"
    region               = "us-east-1"
    iam_instance_profile = "packer-role-test"
    access_key           = "${var.access_key}"
    secret_key           = "${var.secret_key}"
    source_ami   = "ami-0c2b8ca1dad447f8a"
    ssh_username = "ec2-user"
    force_deregister= "true"
    force_delete_snapshot= "true"
 
}

build {
  name = "packer-al2"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    only = ["amazon-ebs.ubuntu"]
    scripts = [
      "scripts/install-chef.sh",
      "scripts/install-fireeye.sh"
    ]
  }

  provisioner "shell" {
    only = ["amazon-ebs.ubuntu"]
    inline = [
      "mkdir -p /etc/packer/files",
      "chown -R ${var.source_ami_ssh_user}:${var.source_ami_ssh_user} /etc/packer/files"
    ]
    execute_command = "echo 'packer' | {{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
  }

  provisioner "file" {
    only        = ["amazon-ebs.ubuntu"]
    source      = "./files/"
    destination = "/etc/packer/files"
  }

  provisioner "shell" {
    only   = ["amazon-ebs.ubuntu"]
    script = "./scripts/al2/boilerplate.sh"
    environment_vars = [
      "HTTP_PROXY=${var.http_proxy}",
      "HTTPS_PROXY=${var.https_proxy}",
      "NO_PROXY=${var.no_proxy}"
    ]
    execute_command   = "echo 'packer' | {{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true
    pause_after       = "15s"
  }


}

variable "source_ami_ssh_user"{
    type    = string
     default= "ec2-user"  
}
variable "http_proxy" {
     type    = string
     default= "" 
}
variable "https_proxy" {
     type    = string
     default= "" 
}
variable "no_proxy" {
     type    = string
     default= "" 
}
variable "ami_prefix" {
  type    = string
  default = "learn-packer-linux-aws-redis"
}

variable "access_key" {
  type    = string
  default = ${{secrets.AWS_ACCESS_KEY}}
}

variable "secret_key" {
  type    = string
  default = ${{secrets.AWS_SECRET_KEY}}
}
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}