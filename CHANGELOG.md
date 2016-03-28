## Unreleased

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
