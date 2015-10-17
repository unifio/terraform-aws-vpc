# Terraform AWS VPC Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master)

Module stack that supports full AWS VPC deployment.  Users can provision a VPC with optional support for
DHCP Options Sets, Virtual Private Gateway creation, and provision one or more availability zones (AZs) each coming with its own NAT setup, external facing (DMZ) and private (LAN) subnets.

## Base Module ##

The Base module provisions the VPC, attaches an Internet Gateway, and creates NAT Security Group and DMZ Routing table

### Input Variables ###

- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `vpc_cidr` - CIDR block for the VPC.
- `enable_dns` - (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true.
- `enable_hostnames` - (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
- `lan_cidr` - Comma separated list of CIDR blocks to be given ingress access to NAT boxes in each subnet.

### Usage ###

```js
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc//base"

  stack_item_label = "mystack1"
  stack_item_fullname = "Stack Item Description"
  vpc_cidr = "10.10.0.0/22"
  enable_dns = true
  enable_hostnames = false
  lan_cidr = "10.10.2.0/25,10.10.2.128/25,10.10.3.0/25"
}
```
### Outputs ###

- `vpc_id` - ID of the VPC
- `igw_id` - ID of the Internet gateway
- `rt_dmz_id` - ID of the DMZ routing table
- `nat_sg_id` - ID of NAT security group

## DHCP module ##

The DHCP module provisions a DHCP options resource and associates it with the specified VPC resource.

### Input Variables ###

- `vpc_id` - ID of the VPC to associate the DHCP Options Set with.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `domain_name` - (Optional) the suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file.
- `name_servers` - (Optional) List of name servers to configure in /etc/resolv.conf.
- `ntp_servers` - (Optional) List of NTP servers to configure.
- `netbios_name_servers` -  (Optional) List of NETBIOS name servers.
- `netbios_node_type` - (Optional) The NetBIOS node type (1, 2, 4, or 8). AWS recommends to specify 2 since broadcast and multicast are not supported in their network. For more information about these node types, see RFC 2132.  Defaults to 2.

### Usage ###

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js

module "dhcp" {
  source = "github.com/terraform-aws-vpc//dhcp"

  vpc_id = "${module.vpc_base.vpc_id}"
  stack_item_label = "mystack1"
  stack_item_fullname = "myname"
  domain_name = "mydomain.com"
  name_servers = "10.128.8.10"
  ntp_servers = "10.128.8.10"
  netbios_name_servers = "10.128.8.10"
  netbios_node_type = 2
}
```
### Outputs ###

- `dhcp_id` - ID of the DHCP Options set

## VPG Module ##

Creates a VPC VPN Gateway

### Input Variables

- `vpc_id` - The VPC to associate the VPG with.
- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.

### Usage

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js

module "vpg" {
  source = "github.com/terraform-aws-vpc//vpg"

  vpc_id = "${module.vpc_base.vpc_id}"
  stack_item_fullname = "Stack Item Description"
  stack_item_label = "mystack1"
}
```

### Outputs ###

- `vpg_id` - ID of the newly created Virtual Private Gateway

## AZ Module ##

In each Availability Zone provided, this module provisions a NAT instance, and creates subnets and routing tables for a public (DMZ) and private (LAN) sub networks.  The remote access information for the NAT instance is output to user data.

### Input Variables ###

- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `vpc_id` - ID of the VPC to use.
- `region` - AWS region to deploy in.
- `az` - Comma separated list of Availability Zones (AZs) in which to create the previously described infrastructure.
- `dmz_cidr` -Comma separated list of CIDR blocks to be used for DMZ subnet.  This list should correspond 1:1 to each AZ.
- `lan_cidr` - Comma separated list of CIDR blocks to be used for LAN subnet.  This list should correspond 1:1 to each AZ.
- `lans_per_az` - The number of private subnets to be provisioned per AZ. You will need to double the CIDR blocks specified in the `lan_cidr` variable for each increase in this value.
- `enable_dmz_public_ips` - Specify true to indicate that instances launched into the subnet should be assigned a public IP address.  Defaults to true.
- `rt_dmz_id` - ID of the DMZ route table for this VPC.
- `ami` - AWS AMI to use when creating NAT instance in each AZ.
- `instance_type` - EC2 instance type to be used.
- `key_name` -  The key name to use for the NAT instances.
- `nat_sg_id` - ID of the NAT security group.
- `user_data_template` - Template to be used to generate user data.  Default is "templates/user_data.tpl".  This template will be passed the following variables:
 * hostname - Name of NAT instance for the current AZ.
 * fqdn - Fully Qualified Domain Name for the NAT instance
 * ssh_user - SSH username to be given NAT access via SSH
- `domain` - Domain name
- `ssh_user` - Username to use when enabling SSH access to NAT instance.  Default is ec2-user.

### Usage ###

The usage examples may assume that previous modules in this stack have already been declared, such as the base module, instantiated as "vpc_base".  This declaration is not necessary, but does promote a consistent and maintainable standard.

```js
module "AZs" {
    source = "github.com/unifio/terraform-aws-vpc//az"

    stack_item_label = "mystack1"
    stack_item_fullname = "Stack Item Description"
    vpc_id = "${module.vpc_base.vpc_id}"
    region = "us-west-2"
    az = "a,b"    
    dmz_cidr = "10.10.0.0/25,10.10.0.128/25,10.10.1.0/25"
    lan_cidr = "10.10.2.0/25,10.10.2.128/25,10.10.3.0/25"
    lans_per_az = "1"
    enable_dmz_public_ips = "true"
    rt_dmz_id = "${module.vpc_base.rt_dmz_id}"
    ami = "ami-xxxxxxxx"
    instance_type = "t2.micro"
    key_name = "ops"
    nat_sg_id = "${module.vpc_base.nat_sg_id}"
    user_data_template = "templates/user_data.tpl"
    domain - "mydomain.com"
    ssh_user = "ec2-user"
}
```
### Outputs ###

- `lan_id` - List of subnet IDs of the LAN subnetworks.  The order and association of the IDs match the order of the availability zones passed to the module.
- `dmz_id` - List of subnet IDs of the DMZ subnetworks.  The order and association of the IDs match the order of the availability zones passed to the module.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

Apache 2 Licensed. See LICENSE for full details.
