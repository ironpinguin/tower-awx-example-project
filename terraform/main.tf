provider "aws" {
  access_key = "${var.aws_accesskey}"
  secret_key = "${var.aws_secretkey}"
  region     = "eu-central-1"
}

data "aws_route53_zone" "aws_grayflowr_zone" {
  name = "${var.aws_dns_zone}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "awx_test_host" {
  name = "awx_test_hosts_access"
  description = "allow http/https and ssh access form every where"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name = "awx test hosts"
  }
}


resource "aws_instance" "awx_host" {
  count = "${var.count_instances}"
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.awx_test_host.name}"]
  tags {
    Name = "awx-host"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y python python-apt apt-transport-https ca-certificates curl software-properties-common git openjdk-8-jdk-headless",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
    }
  }
}

resource "aws_route53_record" "awx_host" {
  count = "${var.count_instances}"
  zone_id = "${data.aws_route53_zone.aws_grayflowr_zone.zone_id}"
  name = "awx-${count.index}.${data.aws_route53_zone.aws_grayflowr_zone.name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.awx_host.*.public_ip, count.index)}"]
}

