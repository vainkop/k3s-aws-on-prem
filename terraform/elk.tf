resource "aws_spot_instance_request" "k3s-elk" {

  wait_for_fulfillment        = true
  associate_public_ip_address = true
  ebs_optimized               = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_id
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg_k3s.id]
  disable_api_termination     = false

  root_block_device {
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = false
    volume_type           = "gp2"
  }

  timeouts {
    create = "20m"
  }

  tags = {
    Name = "k3s-elk"
  }

  volume_tags = {
    Name = "k3s-elk"
  }

  credit_specification {
    cpu_credits = "standard"
  }

}

resource "aws_ec2_tag" "k3s-elk-tags" {
  resource_id = aws_spot_instance_request.k3s-elk.spot_instance_id

  key   = "Name"
  value = "k3s-elk"
}


resource "aws_eip" "k3s-elk" {
  vpc = true
  tags = {
    Name = "k3s-elk"
  }
}

resource "aws_eip_association" "k3s_elk_eip_assoc" {
  instance_id   = aws_spot_instance_request.k3s-elk.spot_instance_id
  allocation_id = aws_eip.k3s-elk.id
}

output "elks_public_ips" {
  value = [aws_eip_association.k3s_elk_eip_assoc.public_ip]
}

resource "null_resource" "k3s-elk-configure" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      echo -e "${aws_eip_association.k3s_elk_eip_assoc.public_ip}" > ../ELK_IP
    EOT
  }

  depends_on = [null_resource.k3s-master-configure, aws_eip_association.k3s_elk_eip_assoc]
}
