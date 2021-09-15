# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "aws_access_key" {
  type    = string
  default = env("AWS_ACCESS_KEY")
}

variable "aws_secret_key" {
  type    = string
  default = env("AWS_SECRET_KEY")
}

variable "source_ami_ssh_user" {
  type    = string
  default = "ec2-user"
}
variable "http_proxy"{
  type    = string
  default = ""

}
variable "no_proxy"{
  type    = string
  default = ""

}
variable "https_proxy"{
  type    = string
  default = ""

}
# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "autogenerated_1" {
  access_key            = "${var.aws_access_key}"
  ami_name              = "packer-ami-maf-hcl-eu-west"
  force_delete_snapshot = "true"
  force_deregister      = "true"
  iam_instance_profile  = "packer-role-test"
  instance_type         = "t2.micro"
  region                = "eu-west-1"
  secret_key            = "${var.aws_secret_key}"
  source_ami            = "ami-02b4e72b17337d6c1"
  ssh_username          = "${var.source_ami_ssh_user}"
  vpc_id                = "vpc-040553a73e17fd97b"
  subnet_id             = "subnet-05a98500f59668967"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "shell" {
    scripts = ["scripts/install-chef.sh", "scripts/install-fireeye.sh"]
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | {{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'"
    inline          = ["mkdir -p /etc/packer/files", "chown -R ${var.source_ami_ssh_user}:${var.source_ami_ssh_user} /etc/packer/files"]
  }

  provisioner "file" {
    destination = "/etc/packer/files"
    source      = "./files/"
  }

  provisioner "shell" {
    environment_vars  = ["HTTP_PROXY=${var.http_proxy}", "HTTPS_PROXY=${var.https_proxy}", "NO_PROXY=${var.no_proxy}"]
    execute_command   = "echo 'packer' | {{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'"
    expect_disconnect = true
    pause_after       = "15s"
    script            = "./scripts/al2/boilerplate.sh"
  }

  provisioner "shell" {
    environment_vars = ["HTTP_PROXY=${var.http_proxy}", "HTTPS_PROXY=${var.https_proxy}", "NO_PROXY=${var.no_proxy}"]
    execute_command  = "echo 'packer' | {{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'"
    scripts          = ["./scripts/al2/cis-benchmark.sh", "./scripts/al2/cleanup.sh"]
  }

}
