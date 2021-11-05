# v0.14.22

Changed
  * Bumped the required azurerm provider version to 2.71.0 as this is required to support the sku_tier argument of the PIP.

# v0.14.0 - 2021-08-04

Breaking
  * Refactored NSG rules loop in order to accept all supported Terraform NSG rule attributes. Requires new input format. See example_adv2 for example usage.

Added
  * Added CHANGELOG.md to document and track module changes