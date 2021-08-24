resource "aws_spot_instance_request" "k3s-worker" {
  count = var.workers_num

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
    Name = "k3s-worker-${count.index + 1}"
  }

  volume_tags = {
    Name = "k3s-worker-${count.index + 1}"
  }

  credit_specification {
    cpu_credits = "standard"
  }

}

resource "aws_ec2_tag" "k3s-worker-tags" {
  count       = var.workers_num
  resource_id = element(aws_spot_instance_request.k3s-worker.*.spot_instance_id, count.index)

  key   = "Name"
  value = "k3s-worker-${count.index + 1}"
}


resource "aws_eip" "k3s-worker" {
  count = var.workers_num
  vpc   = true
  tags = {
    Name = "k3s-worker"
  }
}

resource "aws_eip_association" "k3s_worker_eip_assoc" {
  count         = var.workers_num
  instance_id   = element(aws_spot_instance_request.k3s-worker.*.spot_instance_id, count.index)
  allocation_id = element(aws_eip.k3s-worker.*.id, count.index)
}

output "workers_public_ips" {
  value = [aws_eip_association.k3s_worker_eip_assoc.*.public_ip]
}

resource "null_resource" "k3s-worker-configure" {
  count = var.workers_num

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      echo -e "${aws_eip_association.k3s_worker_eip_assoc[count.index].public_ip}" >> ../WORKER_IPS
    EOT
  }

  depends_on = [null_resource.k3s-master-configure, aws_eip_association.k3s_worker_eip_assoc]
}
