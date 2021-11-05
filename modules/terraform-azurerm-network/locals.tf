locals {
  bas_name = coalesce(lower(var.bas_name), lower("bas-${var.environment}-${var.location_short}-001"))

  configure_fw_threat_intel_allowlist = var.fw_threat_intel_allowlist_ip_addresses != null || var.fw_threat_intel_allowlist_fqdns != null ? true : null

  default_tags = {
    CreationDate = timestamp()
  }

  policy_tags = {
    creationdate = timestamp()
  }
}