resource "aws_instance" "test-instance" {
  count         = var.instance_count
  ami           = element(var.ami_type, count.index)
  instance_type = element(var.instance_type, count.index)
  tags = {
    Name = element(var.instance_tags, count.index)
  }
  associate_public_ip_address = true

  security_groups = [aws_security_group.test-ingress-bastion.id]
  subnet_id       = aws_subnet.test-public_subnet.id
  #subnet_id      = aws_subnet.test-private_subnet.id
  key_name = "key-test"
  # user_data = file("passwd.sh")

  provisioner "remote-exec" {
    inline = [
      "yes `openssl rand -base64 10` | sudo passwd root",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/.ssh/id_rsa_test")
      #wait_for_connection = true

    }
  }

}

## setup elastic IP
#resource "aws_eip" "test-ip-test" {
#  count    = var.instance_count
#  #instance = element(aws_instance.test-instance.*.id, count.index)
#  instance   = aws_instance.test-instance[count.index].id
#  vpc      = true
#}

#output "bastion" {
#  value = aws_eip.test-ip-test.*.public_ip
#}

resource "null_resource" "test" {
  depends_on = [aws_instance.test-instance]
  #count = length(aws_instance.*.id)
  count = var.instance_count
  triggers = {
    instance_id = aws_instance.test-instance[count.index].id
  }
  ##  provisioner "remote-exec" {
  ##    connection {
  ##      host = aws_instance.test-instance[count.index].public_dns
  ##      user = "ubuntu"
  ##      ##file = "~/.ssh/id_rsa_test"
  ##    }
  ##
  ##    inline = ["echo 'link ok'"]
  ##  }


  provisioner "local-exec" {
    command = <<EOF
     ssh -o "IdentitiesOnly=yes" -o "StrictHostKeyChecking=no" -i ~/.ssh/id_rsa_test ubuntu@${element(aws_instance.test-instance.*.public_ip, count.index)} ping -c1 ${element(aws_instance.test-instance.*.private_ip, (count.index + 1) % length(aws_instance.test-instance.*.private_ip))} 
    EOF
  }


}

