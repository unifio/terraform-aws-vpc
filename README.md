# Terraform AWS VPC Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-vpc/tree/master)

Module stack that supports full AWS VPC deployment.  Users can provision a basic VPC with optional support for the following:

* Availability Zone (AZ) provisioning w/ configurable subnet and NAT configuration
* DHCP Options Set
* Virtual Private Gateway creation

## Requirements ##

- Terraform 0.6.14 or newer
- AWS provider

## Base Module ##

The Base module provisions the VPC, attaches an Internet Gateway, and creates NAT Security Group, DMZ Routing table, and creates a CloudWatch group, IAM role, and AWS flow log.  The flow log is configured to capture all traffic (ALLOW and DENY) over the entire VPC.

### Input Variables ###

- `stack_item_label` - Short form identifier for this stack.  This value is used to create the "Name" resource tag for resources created by this stack item, and also serves as a unique key for re-use.
- `stack_item_fullname` - Long form descriptive name for this stack item.  This value is used to create the "application" resource tag for resources created by this stack item.
- `vpc_cidr` - The CIDR block you want the VPC to cover. For example: 10.0.0.0/16.
- `instance_tenacy` - The allowed tenancy of instances launched into the VPC. Defaults to 'default'. Only other option at this time is 'dedicated', which will force any instance launched into the VPC to be dedicated, regardless of the tenancy option specified when the instance is launched.
- `enable_dns` - (Optional) Specifies whether DNS resolution is supported for the VPC. Defaults to true.
- `enable_hostnames` - (Optional) Specifies whether the instances launched in the VPC get DNS hostnames. Defaults to true.
- `enable_classiclink` - (Optional) Specifies whether ClassicLink is enabled for the VPC. Defaults to false.
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
- `flow_log_id` - ID of the AWS flow log

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
- `user_data` - User data to associate with the NAT instance.
- `enable_nats` - Set to "true" to allocate NAT instances for each DMZ subnet.  Default is "true"
- `enable_nat_eip` - Set to "true" to assign an Elastic IP to each of the NAT machines created.  Default is "false"
- `enable_nat_auto_recovery` - Set to "true" or "false".  "false" disables and "true" enables.  If enabled, CloudWatch alarms will be created that will automatically recover the NAT instances, preserving its instance id, ip, etc. in the case of system failure.  Default is "false".  Please check that the AMI used for the NAT supports recovery of its instances.
- `period` - The period in seconds over which a system failure in the NAT instance occurs. Not used if enable_nat_auto_recovery is 0.
- `evaluation_periods` - The number of consecutive periods in which the system failure must occur for the alarm to fire.  Not used if enable_nat_auto_recovery is 0.

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
    user_data = "${template_file.templ.rendered}"
}
```

### Outputs ###

- `lan_id` - List of subnet IDs of the LAN subnetworks.  The order and association of the IDs match the order of the availability zones passed to the module.
- `dmz_id` - List of subnet IDs of the DMZ subnetworks.  The order and association of the IDs match the order of the availability zones passed to the module.
- `nat_eip_id` - List of Elastic IP IDs for each of the NAT machines.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See LICENSE for full details.
