# VPC AZ

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

### Generates NAT instance user data
resource "template_file" "user_data" {
  count = "${length(split(",",var.az))}"
  filename = "${path.root}/templates/${var.user_data_template}"
  vars {
    hostname = "${var.stack_item_label}-nat-${count.index}"
    fqdn = "${var.stack_item_label}-nat-${count.index}.${var.domain}"
    ssh_user = "${var.ssh_user}"
  }
}

### Provisions NAT instance
resource "aws_instance" "nat" {
  count = "${length(split(",",var.az)) * element(split(",",var.lans_per_az_is_zero),var.lans_per_az)}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.nat_sg_id}"]
  subnet_id = "${element(aws_subnet.dmz.*.id,count.index)}"
  source_dest_check = false
  tags {
    Name = "${var.stack_item_label}-nat-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
  user_data = "${element(template_file.user_data.*.rendered, count.index)}"
}

## Add CloudWatch alarm to recover instance in the case of a fault
resource "aws_cloudwatch_metric_alarm" "recover_alarm" {
  ## The use of the lans_per_az_is_zero list is to map any nonzero variable onto a value of 1
  ## and a value of zero variable onto 0.  This is not a foolproof way to do this, since
  ## technically you need an index for every conceivable value, so instead we count on the following:
  ## 1) We have 20 indices, which allows the user up to 20 lans_per_az, which should be plenty
  ## 2) If the user accidentally puts some random value in for lans_per_az or nat_auto_recovery the modulo
  ##    ensures that in the worst case don't get a giant multiplier
  count = "${length(split(",",var.az)) * element(split(",",var.lans_per_az_is_zero),var.lans_per_az) * element(split(",",var.lans_per_az_is_zero),var.nat_auto_recovery)}"
  alarm_name = "${var.stack_item_label}-nat-${count.index}-alarm"
  dimensions = {
    InstanceId = "${element(aws_instance.nat.*.id, count.index)}"
  }
  metric_name = "StatusCheckFailed"
  namespace = "AWS/EC2"
  statistic = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold = "0"
  period = "${var.period}"
  evaluation_periods = "${var.evaluation_periods}"
  alarm_description = "Recover instance upon series of StatusCheckFailed events"
  alarm_actions = [ "arn:aws:automate:${var.region}:ec2:recover" ]
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
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${element(aws_instance.nat.*.id,count.index)}"
  }
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
