# VPC Availability Zone

## Provisions DMZ resources

### Provisions subnet
resource "aws_subnet" "dmz" {
  count = "${length(split(",",var.az))}"
  availability_zone = "${var.region}${element(split(",",var.az),count.index)}"
  cidr_block = "${element(split(",",var.dmz_cidr),count.index)}"
  map_public_ip_on_launch = "${var.enable_dmz_public_ips}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.stack_item_label}-dmz-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_dmz" {
  count = "${length(split(",",var.az))}"
  subnet_id = "${element(aws_subnet.dmz.*.id,count.index)}"
  route_table_id = "${var.rt_dmz_id}"
}

### Provisions NAT gateway
resource "aws_nat_gateway" "nat" {
  count = "${length(split(",",var.az))}"
  allocation_id = "${element(aws_eip.eip_nat.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.dmz.*.id,count.index)}"
}

resource "aws_eip" "eip_nat" {
  count = "${length(split(",",var.az))}"
  vpc = true
}

## Provisions LAN resources

### Provisions subnet
resource "aws_subnet" "lan" {
  count = "${length(split(",",var.az)) * var.lans_per_az}"
  availability_zone = "${var.region}${element(split(",",var.az),count.index)}"
  cidr_block = "${element(split(",",var.lan_cidr),count.index)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.stack_item_label}-lan-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

### Provisions routing table
resource "aws_route_table" "rt_lan" {
  count = "${length(split(",",var.az)) * var.lans_per_az}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.stack_item_label}-lan-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_lan" {
  count = "${length(split(",",var.az)) * var.lans_per_az}"
  subnet_id = "${element(aws_subnet.lan.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.rt_lan.*.id,count.index)}"
}
