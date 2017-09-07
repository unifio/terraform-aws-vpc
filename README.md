# Terraform AWS VPC Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master)

Terraform module for deployment and management of an AWS Virtual Private Cloud (VPC) and related resources.

This module is well suited to both basic and advanced use cases with very few required inputs, but the ability to configure just about every feature available.

## Requirements ##

- Terraform 0.8.0 or newer
- AWS provider

## Quick Start

The following code will yield a fully functioning VPC environment:

```js
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc//base?ref=master"
}

module "az" {
  source = "github.com/unifio/terraform-aws-vpc//az?ref=master"

  vpc_id = "${module.vpc_base.vpc_id}"
```

## Base Module ##

The Base module provisions the VPC, Internet Gateway and DMZ routing table. It additionally enables flow log capture over the entire VPC.

### Input Variables ###

Name | Type | Required | Description
--- | --- | --- | ---
`enable_classiclink` | string | Default: `false` | Specifies whether ClassicLink is enabled for the VPC.
`enable_dns` | string | Default: `true` | Specifies whether DNS resolution is supported for the VPC.
`enable_hostnames` | string | Default: `true` | Specifies whether the instances launched in the VPC get DNS hostnames.
`flow_log_traffic_type` | string | Default: `ALL` | The type of traffic to capture. Valid values: ACCEPT,REJECT,ALL.
`instance_tenancy` | string | Default: `default` | The allowed tenancy of instances launched into the VPC. Only other option at this time is `dedicated`, which will force any instance launched into the VPC to be dedicated, regardless of the tenancy option specified when the instance is launched.
`stack_item_label` | string | Default: `qckstrt` | Short form identifier for this stack. This value is used to create the "Name" tag for resources created by this stack item, and also serves as a unique key for re-use.
`stack_item_fullname` | string | Default: `VPC Quick Start` | Long form descriptive name for this stack item. This value is used to create the "application" tag for resources created by this stack item.
`vpc_cidr` | string | Default: `172.16.0.0/21` | The CIDR block you want the VPC to cover.
`vgw_ids` | string | | A list of virtual gateways to associate with the routing tables for route propagation.

### Usage ###

```js
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc//base?ref=master"

  enable_dns          = "true"
  enable_hostnames    = "false"
  stack_item_fullname = "My Stack"
  stack_item_label    = "mystack"
  vpc_cidr            = "172.16.0.0/21"
}
```

### Outputs ###

Name | Type | Description
--- | --- | ---
`flow_log_id` | string | ID of the AWS flow log.
`igw_id` | string | ID of the Internet gateway.
`rt_dmz_id` | string | ID of the DMZ routing table.
`vpc_id` | string | ID of the VPC.

## DHCP module ##

The DHCP module provisions a DHCP options resource and associates it with the specified VPC resource.

### Input Variables ###

Name | Type | Required | Description
--- | --- | --- | ---
`domain_name` | string | | The suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file.
`name_servers` | list | Default: `["AmazonProvidedDNS"]` | List of name servers to configure in /etc/resolv.conf.
`netbios_name_servers` | list | | List of NETBIOS name servers.
`netbios_node_type` | string | | The NetBIOS node type (1, 2, 4, or 8). AWS recommends to specify 2 since broadcast and multicast are not supported in their network. For more information about these node types, see RFC 2132.
`ntp_servers` | list | | List of NTP servers to configure.
`stack_item_fullname` | string | yes | Long form descriptive name for this stack item. This value is used to create the "application" tag for resources created by this stack item.
`stack_item_label` | string | yes | Short form identifier for this stack. This value is used to create the "Name" tag for resources created by this stack item, and also serves as a unique key for re-use.
`vpc_id` | string | yes | ID of the VPC to associate the DHCP Options Set with.

### Usage ###

```js
module "vpc_base" {
  source = "github.com/terraform-aws-vpc?ref=master//base"
}

module "dhcp" {
  source = "github.com/terraform-aws-vpc?ref=master//dhcp"

  domain_name          = "mydomain.com"
  name_servers         = ["172.16.0.2"]
  netbios_name_servers = ["172.16.0.2"]
  netbios_node_type    = 2
  ntp_servers          = ["172.16.0.2"]
  stack_item_fullname  = "My Stack"
  stack_item_label     = "mystack"
  vpc_id               = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

Name | Type | Description
--- | --- | ---
`dhcp_id` | string | ID of the DHCP Options set.

## VPG Module ##

Creates a VPC VPN Gateway

### Input Variables

Name | Type | Required | Description
--- | --- | --- | ---
`stack_item_fullname` | string | yes | Long form descriptive name for this stack item. This value is used to create the "application" tag for resources created by this stack item.
`stack_item_label` | string | yes | Short form identifier for this stack. This value is used to create the "Name" tag for resources created by this stack item, and also serves as a unique key for re-use.
`vpc_attach` | string | | Specifies whether the VPN gateway should be associated with a VPC.
`vpc_id` | string | | The VPC to associate the VPN gateway with.

### Usage

```js
module "vpc_base" {
  source = "github.com/terraform-aws-vpc?ref=master//base"
}

module "vpg" {
  source = "github.com/terraform-aws-vpc?ref=master//vpg"

  stack_item_fullname = "My Stack"
  stack_item_label    = "mystack"
  vpc_attach          = "true"
  vpc_id              = "${module.vpc_base.vpc_id}"
}
```

### Outputs ###

Name | Type | Description
--- | --- | ---
`vpg_id` | string | ID of the newly created VPN Gateway.

## AZ Module ##

The AZ module provisions subnets, routing tables and NATing. It has support for both Internet facing and private subnets, static and dynamic routing (VPN propagation) as well as gateway or EC2 based NATing. It will handle basic CIDR calculations for up to 4 availability zones and 2 private subnets per availability zone. All parameters are overidable for more advanced configurations.

### Input Variables ###

Name | Type | Required | Description
--- | --- | --- | ---
`azs_provisioned` | string | Default: `2` | The number of availability zones to be provisioned. Either this or **azs\_provisioned\_override** must be specified. Auto-provisioning will support up to 4 AZs without the need for overrides.
`azs_provisioned_override` | list | | List of availability zone letters to be provisioned. Useful in regions where not all AZs are VPC ready. Either this or **azs_provisioned** must be specified.
`dmz_cidrs` | list | | The CIDR block(s) you want the public subnet(s) to cover.
`enable_dmz_public_ips` | string | | Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address.
`lan_cidrs` | list | | The CIDR block(s) you want the LAN subnet(s) to cover.
`lans_per_az` | string | Default: `1` | The number of private subnets to be provisioned per AZ. Auto-provisioning will support up to 2 private subnets per AZ without the need for overrides.
`nat_ami_override` | string | | Custom NAT Amazon Machine Image (AMI).
`nat_eips_enabled` | string | Default: `false` | Flag for specifying allocation of Elastic IPs to NATs for the purposes of whitelisting. This value is overriden to `true` when utilizing NAT gateways.
`nat_gateways_enabled` | string | Default: `false` | Flag for specifying utilization of managed NAT gateways over EC2 based NAT instances.
`nat_instance_type` | string | Default: `t2.nano` | NAT EC2 instance type.
`nat_key_name` | string | | Name of the EC2 key pair to install on EC2 based NAT instances.
`rt_dmz_id` | string | yes | The ID of the DMZ routing table.
`stack_item_fullname` | string | Default: `VPC Quick Start` | Long form descriptive name for this stack item. This value is used to create the "application" tag for resources created by this stack item.
`stack_item_label` | string | Default: `qckstrt` | Short form identifier for this stack. This value is used to create the "Name" tag for resources created by this stack item, and also serves as a unique key for re-use.
`vgw_ids` | list | | A list of virtual gateways to associate with the routing tables for route propagation.
`vpc_id` | string | yes | ID of the VPC.

### Usage ###

```js
module "vpc_base" {
  source = "github.com/terraform-aws-vpc//base?ref=master"
}

module "az" {
  source = "github.com/unifio/terraform-aws-vpc//az?ref=master"

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

Name | Type | Description
--- | --- | ---
`dmz_ids` | list | List of subnet IDs of the DMZ subnetworks.
`lan_ids` | list | List of subnet IDs of the LAN subnetworks.
`dmz_cidrs` | list | List of subnet CIDR blocks of the DMZ subnetworks.
`lan_cidrs` | list | List of subnet CIDR blocks of the LAN subnetworks.
`eip_nat_ids` | list | List of Elastic IP IDs for each of the NAT gateways.
`nat_ids` | list | List of NAT gateways IDs.
`eip_nat_ips` | list | List of NAT gateway public IPs.
`rt_lan_ids` | list | List of routing table IDs for the LAN subnets.

## Peer Module ##

Creates a VPC peering connection

### Input Variables

Name | Type | Required | Description
--- | --- | --- | ---
`accepter_allow_classic_link_to_remote` | string | | Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC.
`accepter_allow_remote_dns` | string | Default: `false` | Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC.
`accepter_allow_to_remote_classic_link` | string | | Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection.
`accepter_auto_accept` | string | | Accept the peering (both VPCs need to be in the same AWS account).
`accepter_owner_id` | string | | The AWS account ID of the owner of the peer VPC.
`accepter_vpc_id` | string | | The ID of the VPC with which you are creating the VPC Peering Connection.
`requester_allow_classic_link_to_remote` | string | | Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC.
`requester_allow_remote_dns` | string | Default: `false` | Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC.
`requester_allow_to_remote_classic_link` | string | | Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection.
`requester_vpc_id` | string | | The ID of the requester VPC.
`stack_item_fullname` | string | yes | Long form descriptive name for this stack item. This value is used to create the "application" tag for resources created by this stack item.
`stack_item_label` | string | yes | Short form identifier for this stack. This value is used to create the "Name" tag for resources created by this stack item, and also serves as a unique key for re-use.

### Usage

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

Name | Type | Description
--- | --- | ---
`peer_connection_id` | string | ID of the newly created peering connection.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See LICENSE for full details.
