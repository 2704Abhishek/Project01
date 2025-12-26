data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "random_id" "random_node_Id" {
  byte_length = 2
  count       = var.main_instance_count
}

# -----------------------------
# SSH KEY FOR TERRAFORM
# -----------------------------
data "aws_key_pair" "terraform_key" {
  key_name = "terraform_key_v2"
}

# -----------------------------
# EC2 INSTANCE
# -----------------------------
resource "aws_instance" "web_server" {
  count                  = var.main_instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.project_sg_1.id]

  key_name = data.aws_key_pair.terraform_key.key_name

  user_data = templatefile("${path.module}/main-userdata.tpl", {
    new_hostname = "web-server-${random_id.random_node_Id[count.index].dec}"
  })

  tags = {
    Name = "WebServerInstance"
  }


  # -----------------------------
  # SAVE ONLY LATEST PUBLIC IP
  # -----------------------------
  # provisioner "local-exec" {
  #   interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  #   command     = "echo '${self.public_ip}' > aws_hosts"
  # }

  # # REMOVE FILE ON DESTROY
  # provisioner "local-exec" {
  #   when        = destroy
  #   interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  #   command     = "rm -f aws_hosts"
  # }

  
}

# -----------------------------
# SSH KEY PATHS
# -----------------------------
# locals {
#   windows_key_path = "C:/Users/Abhishek Yadav/.ssh/terraform_key"
#   wsl_key_path     = "~/.ssh/terraform_key"
# }


# -----------------------------
# ANSIBLE PROVISIONER
# -----------------------------
# resource "null_resource" "grafana_provisioner" {
#   depends_on = [aws_instance.web_server]

#   connection {
#     type        = "ssh"
#     host        = aws_instance.web_server[0].public_ip
#     user        = "ubuntu"
#     private_key = file(local.windows_key_path)
#     timeout     = "2m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Connection test successful: instance is reachable via SSH'"
#     ]
#   }

  # -----------------------------
  # ANSIBLE RUN (FIXED)
  # -----------------------------
#   provisioner "local-exec" {
#     interpreter = ["wsl", "bash", "-c"]
#     command = "ANSIBLE_CONFIG=~/ansible.cfg ansible-playbook --private-key ${local.wsl_key_path} /playbook/grafana.yml"
  

#   }

# }

# old Ansible host key cmd
# "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_CONFIG=~/ansible.cfg ansible all --private-key='~/.ssh/terraform_key' -i aws_hosts -u ubuntu -m ping"