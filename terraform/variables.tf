variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type        = string
  default     = "t3a.large"
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
}

variable "volume_size" {
  type        = string
  description = "Volume size."
  default     = "100"
}

variable "workers_num" {
  type    = string
  default = "3"
}

variable "ssh_key_id" {
  type    = string
  default = "valerii-globaldots"
}

variable "vpc_id" {
  type    = string
  default = "vpc-6516271f"
}

variable "subnet_id" {
  type    = string
  default = "subnet-911aafdc"
}

variable "K3S_TOKEN" {
  type    = string
  default = "U88bSt5PrhJJZRCd"
}

variable "INSTALL_K3S_VERSION" {
  type    = string
  default = "v1.21.4+k3s1"
}