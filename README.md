# Terraform AWS VPC Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master)

Module stack that supports full AWS VPC deployment.  Users can provision a basic VPC with optional support for the following:

* Availability Zone (AZ) provisioning w/ configurable subnet and NAT configuration
* DHCP Options Set
* Virtual Private Gateway creation

## Requirements ##

- Terraform 0.8.0 or newer
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

  enable_dns          = "true"
  enable_hostnames    = "false"
  stack_item_fullname = "My Stack"
  stack_item_label    = "mystck"
  vpc_cidr            = "172.16.0.0/21"
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
- `netbios_node_type` - (Optional) The NetBIOS node type (1, 2, 4, or 8). AWS recommends to specify 2 since broadcast and multicast are not supported in their network. For more information about these node types, see RFC 2132.
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
  name_servers         = ["172.16.0.2"]
  netbios_name_servers = ["172.16.0.2"]
  netbios_node_type    = 2
  ntp_servers          = ["172.16.0.2"]
  stack_item_fullname  = "My Stack"
  stack_item_label     = "mystck"
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
- `vpc_attach` - (Optional) Specifies whether the VPG should be associated with a VPC.
- `vpc_id` - (Optional) The VPC to associate the VPG with.

### Usage

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "vpg" {
  source = "github.com/terraform-aws-vpc?ref=master//vpg"

  stack_item_fullname = "My Stack"
  stack_item_label    = "mystck"
  vpc_attach          = 1
  vpc_id              = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

- `vpg_id` - ID of the newly created Virtual Private Gateway

## AZ Module ##

In each Availability Zone provided, this module provisions subnets and routing tables for a public (DMZ) and private (LAN) sub-networks.

### Input Variables ###

- `azs_provisioned` - (Optional) The number of availability zones to be provisioned. Either this or **azs\_provisioned\_override** must be specified.
- `azs_provisioned_override` - List of availability zone letters to be provisioned. Useful in regions where not all AZs are VPC ready. Either this or **azs_provisioned** must be specified.
- `dmz_cidrs` - (Optional) The CIDR block(s) you want the DMZ subnet(s) to cover.
- `enable_dmz_public_ips` - (Optional) Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address.
- `lan_cidrs` - (Optional) The CIDR block(s) you want the LAN subnet(s) to cover.
- `lans_per_az` - (Optional) The number of private LAN subnets to be provisioned per AZ. Auto-provisioning will support up to 2 LANs without the need for overrides.
- `nat_ami_override` - (Optional) Custom NAT Amazon machine image.
- `nat_eips_enabled` - (Optional) Flag for specifying allocation of Elastic IPs to NATs for the purposes of whitelisting. This value is overriden to 'true' when utilizing NAT gateways.
- `nat_gateways_enabled` - (Optional) Flag for specifying utilization of managed NAT gateways over EC2 based NAT instances.
- `nat_instance_type` - (Default: t2.nano) NAT EC2 instance type.
- `nat_key_name` - (Optional) NAT EC2 key pair name.
- `rt_dmz_id` - The ID of the DMZ routing table.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `vgw_ids` - (Optional) A list of virtual gateways to associate with the routing tables for route propagation.
- `vpc_id` - ID of the VPC.

### Usage ###

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "az" {
  source = "github.com/unifio/terraform-aws-vpc?ref=master//az"

  azs_provisioned       = 2
  enable_dmz_public_ips = "true"
  rt_dmz_id             = "${module.vpc_base.rt_dmz_id}"
  stack_item_fullname   = "My Stack"
  stack_item_label      = "mystck"
  vgw_ids               = "${aws_vpn_gateway.vpg.id}"
  vpc_id                = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

** The order and association of the IDs match the order of the availability zones passed to the module.

- `dmz_ids` - Comma-delimeted list of subnet IDs of the DMZ subnetworks.
- `lan_ids` - Comma-delimeted list of subnet IDs of the LAN subnetworks.
- `dmz_cidrs` - Comma-delimeted list of subnet CIDR blocks of the DMZ subnetworks.
- `lan_cidrs` - Comma-delimeted list of subnet CIDR blocks of the LAN subnetworks.
- `eip_nat_ids` - Comma-delimeted list of Elastic IP IDs for each of the NAT gateways.
- `nat_ids` - Comma-delimeted list of NAT gateways IDs.
- `eip_nat_ips` - Comma-delimeted list of NAT gateway public IPs.
- `rt_lan_ids` - Comma-delimeted list of routing table IDs for the LAN subnets.

## Peer Module ##

Creates a VPC peering connection

### Input Variables

- `accepter_allow_classic_link_to_remote` - Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC.
- `accepter_allow_remote_dns` - Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC.
- `accepter_allow_to_remote_classic_link` - Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection.
- `accepter_auto_accept` - Accept the peering (both VPCs need to be in the same AWS account).
- `accepter_owner_id` - The AWS account ID of the owner of the peer VPC.
- `accepter_vpc_id` - The ID of the VPC with which you are creating the VPC Peering Connection.
- `requester_allow_classic_link_to_remote` - Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC.
- `requester_allow_remote_dns` - Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC.
- `requester_allow_to_remote_classic_link` - Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection.
- `requester_vpc_id` - The ID of the requester VPC.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.

### Usage

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "vpc_peer" {
  source = "github.com/terraform-aws-vpc?ref=master//peer"

  accepter_allow_remote_dns  = "false"
  accepter_owner_id          = "${var.peer_owner_id}"
  accepter_vpc_id            = "${var.peer_vpc_id}"
  requester_allow_remote_dns = "true"
  requester_vpc_id           = "${var.owner_vpc_id}"
  stack_item_fullname        = "${var.stack_item_fullname}"
  stack_item_label           = "${var.stack_item_label}"
}
```

### Outputs ###

- `peer_connection_id` - ID of the newly created peering connection.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See LICENSE for full details.
