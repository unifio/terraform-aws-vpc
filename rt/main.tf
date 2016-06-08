# Route table

resource "aws_route_table" "rt" {
  count  = "${(var.vgw_prop + 1 % 2) * var.rt_count}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.stack_item_label}-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}

resource "aws_route_table" "rt_vgw_prop" {
  count            = "${var.vgw_prop * var.rt_count}"
  vpc_id           = "${var.vpc_id}"
  propagating_vgws = ["${split(",",var.vgw_ids)}"]

  tags {
    Name        = "${var.stack_item_label}-${count.index}"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}
