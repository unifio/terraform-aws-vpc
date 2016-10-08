## Unreleased

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
