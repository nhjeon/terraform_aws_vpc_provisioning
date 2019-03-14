resource "aws_security_group" "bastion" {
  name        = "bastion"
  vpc_id      = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.default_vpc_name}_bastion_security_group"
  }
}

resource "aws_instance" "bastion" {
  ami               = "${var.ami_id}"
  availability_zone = "${aws_subnet.public1.availability_zone}"
  instance_type     = "t2.nano"
  key_name          = "${var.key_pair_name}"

  vpc_security_group_ids = [
    "${aws_default_security_group.default.id}",
    "${aws_security_group.bastion.id}",
  ]

  subnet_id                   = "${aws_subnet.public1.id}"
  associate_public_ip_address = true

  tags {
    Name = "${var.default_vpc_name}_bastion"
  }
}

resource "aws_eip" "bastion" {
  vpc        = true
  instance   = "${aws_instance.bastion.id}"
  depends_on = ["aws_internet_gateway.igw"]
}