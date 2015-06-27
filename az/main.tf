# VPC AZ

## Provisions DMZ resources

### Provisions subnet
resource "aws_subnet" "dmz" {
        count = "${var.az_count}"
        availability_zone = "${var.region}${element(split(",",var.az),count.index)}"
        cidr_block = "${element(split(",",var.dmz_cidr),count.index)}"
        map_public_ip_on_launch = "${var.enable_dmz_public_ips}"
        vpc_id = "${var.vpc_id}"
        tags {
                Name = "${var.app_label}-dmz-${count.index}"
                application = "${var.app_name}"
                managed_by = "terraform"
        }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_dmz" {
        count = "${var.az_count}"
        subnet_id = "${element(aws_subnet.dmz.*.id,count.index)}"
        route_table_id = "${var.rt_dmz_id}"
}

### Generates NAT instance user data
resource "template_file" "user_data" {
        count = "${var.az_count}"
        filename = "${path.root}/templates/${var.user_data_template}"
        vars {
                hostname = "${var.app_label}-nat-${count.index}"
                fqdn = "${var.app_label}-nat-${count.index}.${var.domain}"
                ssh_user = "${var.ssh_user}"
        }
}

### Provisions NAT instance
resource "aws_instance" "nat" {
        count = "${var.az_count}"
        ami = "${var.ami}"
        availability_zone = "${var.region}${element(split(",",var.az),count.index)}"
        instance_type = "${var.instance_type}"
        key_name = "${var.key_name}"
        vpc_security_group_ids = ["${var.nat_sg_id}"]
        subnet_id = "${element(aws_subnet.dmz.*.id,count.index)}"
        source_dest_check = false
        tags {
                Name = "${var.app_label}-nat-${count.index}"
                application = "${var.app_name}"
                managed_by = "terraform"
        }
        user_data = "${element(template_file.user_data.*.rendered, count.index)}"
}

## Provisions LAN resources

### Provisions subnet
resource "aws_subnet" "lan" {
        count = "${var.az_count}"
        availability_zone = "${var.region}${element(split(",",var.az),count.index)}"
        cidr_block = "${element(split(",",var.lan_cidr),count.index)}"
        vpc_id = "${var.vpc_id}"
        tags {
                Name = "${var.app_label}-lan-${count.index}"
                application = "${var.app_name}"
                managed_by = "terraform"
        }
}

### Provisions routing table
resource "aws_route_table" "rt_lan" {
        count = "${var.az_count}"
        vpc_id = "${var.vpc_id}"
        route {
                cidr_block = "0.0.0.0/0"
                instance_id = "${element(aws_instance.nat.*.id,count.index)}"
        }
        tags {
                Name = "${var.app_label}-lan-${count.index}"
                application = "${var.app_name}"
                managed_by = "terraform"
        }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_lan" {
        count = "${var.az_count}"
        subnet_id = "${element(aws_subnet.lan.*.id,count.index)}"
        route_table_id = "${element(aws_route_table.rt_lan.*.id,count.index)}"
}
