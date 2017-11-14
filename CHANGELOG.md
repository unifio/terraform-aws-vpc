#### Consider Implementing:
* ipv6 support

## 0.3.3 (November 13, 2017)

#### IMPROVEMENTS / NEW FEATURES:
* Add 'enable' flag for DHCP.  Default is true.  This allows for stacks to include these based on variable since at this time you cannot conditionally include modules.

## 0.3.2 (May 16, 2017)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* The following output variables have been changed:
  * az module
    * `dmz_cidrs (string)` -> `dmz_cidrs (list)`
    * `dmz_ids (string)` -> `dmz_ids (list)`
    * `eip_nat_ids (string)` -> `eip_nat_ids (list)`
    * `eip_nat_ips (string)` -> `eip_nat_ips (list)`
    * `lan_ids (string)` -> `lan_ids (list)`
    * `lan_cidrs (string)` -> `lan_cidrs (list)`
    * `nat_ids (string)` -> `nat_ids (list)`
    * `rt_lan_ids (string)` -> `rt_lan_ids (list)`
* The following input variable have been changed:
  * az module
    * `stack_item_fullname` now defaults to a value of `VPC Quick Start`
    * `stack_item_label` now defaults to a value of `exmpl`

## 0.3.1 (April 23, 2017)

#### IMPROVEMENTS / NEW FEATURES:
* DHCP defaults are now more minimal and do not set values for all parameters.

## 0.3.0 (April 3, 2017)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* Enabled complex variable types, which are only supported in Terraform 0.7.0 and newer.
* The following input variables have been removed
  * peer module
    * `multi_acct`
* The following input variables have been changed:
  * az module
    * `az (string, required)` -> `azs (list, optional)`
    * `dmz_cidr (string, required)` -> `dmz_cidrs (list, optional)`
    * `lan_cidr (string, required)` -> `lan_cidrs (list, optional)`
    * `vgw_ids (string, optional` - > `vgw_ids (list, optional)`
  * dhcp module
    * `name_servers (string, optional)` -> `name_servers (list, optional)`
    * `netbios_name_servers (string, optional)` -> `netbios_name_servers (list, optional)`
    * `ntp_servers (string, optional)` -> `ntp_servers (list, optional)`
  * peer module
    * `peer_owner_id (string, required)` -> `accepter_owner_id (string, optional)`
    * `peer_vpc_id (string, required)` -> `accepter_vpc_id (string, optional)`
    * `vpc_id (string, required)` -> `requester_vpc_id (string, optional)`
* The following output variables have been changed:
  * az module
    * `dmz_cidr (string)` -> `dmz_cidrs (string)`
    * `dmz_id (string)` -> `dmz_ids (string)`
    * `eip_nat_id (string)` -> `eip_nat_ids (string)`
    * `eip_nat_ip (string)` -> `eip_nat_ips (string)`
    * `lan_id (string)` -> `lan_ids (string)`
    * `lan_cidr (string)` -> `lan_cidrs (string)`
    * `nat_id (string)` -> `nat_ids (string)`
  * base module
    * `dmz_subnet_id (string)` -> `dmz_subnet_ids (string)`
    * `lan_subnet_id (string)` -> `lan_subnet_ids (string)`
    * `lan_rt_id (string)` -> `lan_rt_ids (string)`

#### IMPROVEMENTS / NEW FEATURES:
* Added conditional support for the following parameters:
  * az module
    * `azs`
    * `dmz_cidrs`
    * `enable_dmz_public_ips`
    * `nat_key_name`
  * base module
    * `enable_classiclink`
    * `enable_dns`
    * `enable_hostnames`
    * `instance_tenancy`
  * peer module
    * `accepter_allow_clasic_link_to_remote`
    * `accepter_allow_to_remote_classic_link`
    * `accepter_auto_accept`
    * `requester_allow_clasic_link_to_remote`
    * `requester_allow_to_remote_classic_link`
  * vpg module
    * `availability_zone`

* Added support for AZ auto-provisioning.
* Re-enabled support for EC2 based NATs.
* Added conditional support for EIPs with EC2 based NATs.

## 0.2.5 (October 7, 2016)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* Unattached VPN gateways created by previous versions of this module will be destroyed and recreated on update due to changes in resource naming.
* This module has been verified for compatiblity with Terraform 0.7.5.

#### FEATURES:
* Added support for establishing VPC peering connections.

#### BUG FIXES:
* Resolved issue where changing the attached status of a VPN gateway would result in the resource being destroyed and recreated.

## 0.2.4 (June 24, 2016)

#### IMPROVEMENTS:
* Added NAT gateway public IP to the AZ module outputs.

## 0.2.3 (June 8, 2016)

#### IMPROVEMENTS:
* Added support for VGW route propagation for routing tables.
* Added support for VPG creation without VPC attachment. Necessary to avoid chicken-and-egg scenario when configuring VPC for VPG route propagation.

## 0.2.2 (June 2, 2016)

#### IMPROVEMENTS:
* Verified with Terraform v0.6.16.

## 0.2.1 (May 16, 2016)

#### FEATURES:
* Exposed subnet CIDR blocks as AZ module outputs.

#### IMPROVEMENTS:
* Verified with Terraform v0.6.15.
* Updated formatting to HashiCorp standard.
* Expanded examples to include new VPC resources.

## 0.2.0 (Apr 20, 2016)

#### FEATURES:
* Added support for configuring instance tenancy.
* Added support for enabling ClassicLink.

#### IMPROVEMENTS:
* Verified with Terraform v0.6.14.
* Migrated NAT features to VPC NAT gateway.

## 0.1.1 (Dec 1, 2015)

#### FEATURES:
* Added support for assigning Elastic IP address to each NAT instance.
* Added support for disabling the provisioning of NAT instances [GH-3]
* Added support for auto-recovery of NAT instances
* Added support for VPC flow logs [GH-1]

#### IMPROVEMENTS:
* Updated template_file usage for 0.6.7 to remove deprecation warnings [GH-10]
* Replaced user_data template and parameters with generic user_data param.

## 0.1.0 (Oct 21, 2015)

* Initial Release
