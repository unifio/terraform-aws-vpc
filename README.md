# Terraform AWS VPC Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master)

Module stack that supports full AWS VPC deployment.  Users can provision a basic VPC with optional support for the following:

* Availability Zone (AZ) provisioning w/ configurable subnet and NAT configuration
* DHCP Options Set
* Virtual Private Gateway creation

## Requirements ##

- Terraform 0.6.16 or newer
- AWS provider

## Base Module ##

The Base module provisions the VPC, attaches an Internet Gateway, and creates NAT Security Group, DMZ Routing table, and creates a CloudWatch group, IAM role, and AWS flow log.  The flow log is configured to capture all traffic (ALLOW and DENY) over the entire VPC.

### Input Variables ###

- `enable_classiclink` - (Optional) Specifies whether ClassicLink is enabled for the VPC. Defaults to false.
- `enable_dns` - (Optional) Specifies whether DNS resolution is supported for the VPC. Defaults to true.
- `enable_hostnames` - (Optional) Specifies whether the instances launched in the VPC get DNS hostnames. Defaults to true.
- `flow_log_traffic_type` - (Optional) The type of traffic to capture. Valid values: ACCEPT,REJECT,ALL.
- `instance_tenacy` - The allowed tenancy of instances launched into the VPC. Defaults to 'default'. Only other option at this time is 'dedicated', which will force any instance launched into the VPC to be dedicated, regardless of the tenancy option specified when the instance is launched.
- `rt_vgw_prop` - (Optional) Specifies whether virtual gateway route propagation should be enabled on the routing table(s). Valid values: 0 or 1. Defaults to 0 (disabled).
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `vpc_cidr` - The CIDR block you want the VPC to cover. For example: 10.0.0.0/16.
- `vgw_ids` - (Optional) A list of virtual gateways to associate with the routing tables for route propagation.

### Usage ###

```js
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc?ref=master//base"

  enable_dns          = true
  enable_hostnames    = false
  stack_item_fullname = "Stack Item Description"
  stack_item_label    = "mystack1"
  vpc_cidr            = "10.10.0.0/22"
}
```

### Outputs ###

- `flow_log_id` - ID of the AWS flow log.
- `igw_id` - ID of the Internet gateway.
- `rt_dmz_id` - ID of the DMZ routing table.
- `vpc_id` - ID of the VPC.

## DHCP module ##

The DHCP module provisions a DHCP options resource and associates it with the specified VPC resource.

### Input Variables ###

- `domain_name` - (Optional) The suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file.
- `name_servers` - (Optional) List of name servers to configure in /etc/resolv.conf.
- `netbios_name_servers` -  (Optional) List of NETBIOS name servers.
- `netbios_node_type` - (Optional) The NetBIOS node type (1, 2, 4, or 8). AWS recommends to specify 2 since broadcast and multicast are not supported in their network. For more information about these node types, see RFC 2132.  Defaults to 2.
- `ntp_servers` - (Optional) List of NTP servers to configure.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `vpc_id` - ID of the VPC to associate the DHCP Options Set with.

### Usage ###

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "dhcp" {
  source = "github.com/terraform-aws-vpc?ref=master//dhcp"

  domain_name          = "mydomain.com"
  name_servers         = "10.128.8.10"
  netbios_name_servers = "10.128.8.10"
  netbios_node_type    = 2
  ntp_servers          = "10.128.8.10"
  stack_item_fullname  = "myname"
  stack_item_label     = "mystack1"
  vpc_id               = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

- `dhcp_id` - ID of the DHCP Options set.

## VPG Module ##

Creates a VPC VPN Gateway

### Input Variables

- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `vpc_attach` - Specifies whether the VPG should be associated with a VPC. Valid value: 0 or 1. Defaults to 0 (unattached).
- `vpc_id` - The VPC to associate the VPG with.

### Usage

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "vpg" {
  source = "github.com/terraform-aws-vpc?ref=master//vpg"

  stack_item_fullname = "Stack Item Description"
  stack_item_label    = "mystack1"
  vpc_attach          = 1
  vpc_id              = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

- `vpg_id` - ID of the newly created Virtual Private Gateway

## AZ Module ##

In each Availability Zone provided, this module provisions subnets and routing tables for a public (DMZ) and private (LAN) sub-networks.

### Input Variables ###

- `az` - Availability zone(s).  Will accept a comma delimited string.
- `dmz_cidr` - The CIDR block(s) you want the DMZ subnet(s) to cover.  Will accept a comma delimited string.  This list should correspond 1:1 to each AZ.
- `enable_dmz_public_ips` - (Optional) Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address.  Defaults to true.
- `lan_cidr` - The CIDR block(s) you want the LAN subnet(s) to cover.  Will accept a comma delimited string.  This list should correspond 1:1 to each AZ.
- `lans_per_az` - (Optional) The number of private LAN subnets to be provisioned per AZ.  You will need to double the CIDR blocks specified in the `lan_cidr` variable for each increase in this value.  Defaults to 1.
- `region` - The AWS region.
- `rt_dmz_id` - The ID of the DMZ routing table.
- `rt_vgw_prop` - (Optional) Specifies whether virtual gateway route propagation should be enabled on the routing table(s). Valid values: 0 or 1. Defaults to 0 (disabled).
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `vgw_ids` - (Optional) A list of virtual gateways to associate with the routing tables for route propagation.
- `vpc_id` - ID of the VPC.

### Usage ###

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "az" {
  source = "github.com/unifio/terraform-aws-vpc?ref=master//az"

  az                    = "a,b"
  dmz_cidr              = "10.10.0.0/25,10.10.0.128/25,10.10.1.0/25"
  enable_dmz_public_ips = true
  lan_cidr              = "10.10.2.0/25,10.10.2.128/25,10.10.3.0/25"
  lans_per_az           = "1"
  region                = "us-west-2"
  rt_dmz_id             = "${module.vpc_base.rt_dmz_id}"
  rt_vgw_prop           = 1
  stack_item_fullname   = "Stack Item Description"
  stack_item_label      = "mystack1"
  vgw_ids               = "${aws_vpn_gateway.vpg.id}"
  vpc_id                = "${module.vpc_base.vpc_id}" 
}
```

### Outputs ###

** The order and association of the IDs match the order of the availability zones passed to the module.

- `dmz_id` - List of subnet IDs of the DMZ subnetworks.
- `lan_id` - List of subnet IDs of the LAN subnetworks.
- `dmz_cidr` - List of subnet CIDR blocks of the DMZ subnetworks.
- `lan_cidr` - List of subnet CIDR blocks of the LAN subnetworks.
- `eip_nat_id` - List of Elastic IP IDs for each of the NAT gateways.
- `nat_id` - List of NAT gateways IDs.
- `eip_nat_ip` - List of NAT gateway public IPs.
- `rt_lan_id` - List of routing table IDs for the LAN subnets.

## Peer Module ##

Creates a VPC peering connection

### Input Variables

- `accepter_allow_remote_dns` - Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC.
- `multi_acct` - Flag indicating whether the peering connection spans multiple AWS accounts.
- `peer_owner_id` - The AWS account ID of the owner of the peer VPC.
- `peer_vpc_id` - The ID of the VPC with which you are creating the VPC Peering Connection.
- `requester_allow_remote_dns` - Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `vpc_id` - The ID of the requester VPC.

### Usage

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "vpc_peer" {
  source = "github.com/terraform-aws-vpc?ref=master//peer"

  accepter_allow_remote_dns  = false
  peer_owner_id              = "${var.peer_owner_id}"
  peer_vpc_id                = "${var.peer_vpc_id}"
  requester_allow_remote_dns = true
  stack_item_fullname        = "${var.stack_item_fullname}"
  stack_item_label           = "${var.stack_item_label}"
  vpc_id                     = "${var.owner_vpc_id}"
}
```

### Outputs ###

- `peer_connection_id` - ID of the newly created peering connection.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See LICENSE for full details.
