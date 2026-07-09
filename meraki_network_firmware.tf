# ── Data source: read available versions per network at plan time ─────────────
locals {
  networks_firmware_upgrades_config = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for network in try(organization.networks, []) : {
          key        = format("%s/%s/%s", domain.name, organization.name, network.name)
          network_id = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, network.name)]
          } if(
          try(network.firmware.automatic_upgrade_window, null) != null ||
          try(network.firmware.upgrade, null) != null ||
          try(network.firmware.downgrade, null) != null
        )
      ]
    ]
  ])
}

data "meraki_network_firmware_upgrades_data" "networks_firmware_data" {
  for_each   = { for v in local.networks_firmware_upgrades_config : v.key => v }
  network_id = each.value.network_id
}

# Per-network map: {product → {short_name → id}} — resolves YAML version names to numeric IDs
locals {
  networks_firmware_version_maps = {
    for fw_upgrade_cfg in local.networks_firmware_upgrades_config : fw_upgrade_cfg.key => {
      switch = try({
        for v in data.meraki_network_firmware_upgrades_data.networks_firmware_data[fw_upgrade_cfg.key].products_switch_available_versions :
        v.short_name => v.id
      }, {})
      wireless = try({
        for v in data.meraki_network_firmware_upgrades_data.networks_firmware_data[fw_upgrade_cfg.key].products_wireless_available_versions :
        v.short_name => v.id
      }, {})
      appliance = try({
        for v in data.meraki_network_firmware_upgrades_data.networks_firmware_data[fw_upgrade_cfg.key].products_appliance_available_versions :
        v.short_name => v.id
      }, {})
      cellular_gateway = try({
        for v in data.meraki_network_firmware_upgrades_data.networks_firmware_data[fw_upgrade_cfg.key].products_cellular_gateway_available_versions :
        v.short_name => v.id
      }, {})
      switch_catalyst = try({
        for v in data.meraki_network_firmware_upgrades_data.networks_firmware_data[fw_upgrade_cfg.key].products_switch_catalyst_available_versions :
        v.short_name => v.id
      }, {})
    }
  }
}

locals {
  networks_firmware_upgrades = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for network in try(organization.networks, []) : {
          key        = format("%s/%s/%s", domain.name, organization.name, network.name)
          network_id = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, network.name)]

          upgrade_window_day_of_week = try(network.firmware.automatic_upgrade_window.day_of_week, local.defaults.meraki.domains.organizations.networks.firmware.automatic_upgrade_window.day_of_week, null)
          upgrade_window_hour_of_day = try(network.firmware.automatic_upgrade_window.hour_of_day, local.defaults.meraki.domains.organizations.networks.firmware.automatic_upgrade_window.hour_of_day, null)

          products_switch_participate_in_next_beta_release = try(network.firmware.upgrade.products.switch.participate_in_next_beta_release, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch.participate_in_next_beta_release, null)
          products_switch_next_upgrade_time                = try("${network.firmware.upgrade.products.switch.next_upgrade.local_time}Z", null)
          products_switch_next_upgrade_to_version_id = try(
            local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)].switch[try(network.firmware.upgrade.products.switch.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch.next_upgrade.to_version, "")],
            try(network.firmware.upgrade.products.switch.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch.next_upgrade.to_version, null)
          )

          products_switch_catalyst_participate_in_next_beta_release = try(network.firmware.upgrade.products.switch_catalyst.participate_in_next_beta_release, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch_catalyst.participate_in_next_beta_release, null)
          products_switch_catalyst_next_upgrade_time                = try("${network.firmware.upgrade.products.switch_catalyst.next_upgrade.local_time}Z", null)
          products_switch_catalyst_next_upgrade_to_version_id = try(
            local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)].switch_catalyst[try(network.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, "")],
            try(network.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, null)
          )

          products_wireless_participate_in_next_beta_release = try(network.firmware.upgrade.products.wireless.participate_in_next_beta_release, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.participate_in_next_beta_release, null)
          products_wireless_next_upgrade_time                = try("${network.firmware.upgrade.products.wireless.next_upgrade.local_time}Z", null)
          products_wireless_next_upgrade_predownload_enabled = try(network.firmware.upgrade.products.wireless.next_upgrade.pre_download, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.pre_download, null)
          products_wireless_next_upgrade_to_version_id = try(
            local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)].wireless[try(network.firmware.upgrade.products.wireless.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.to_version, "")],
            try(network.firmware.upgrade.products.wireless.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.to_version, null)
          )

          products_appliance_participate_in_next_beta_release = try(network.firmware.upgrade.products.appliance.participate_in_next_beta_release, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.appliance.participate_in_next_beta_release, null)
          products_appliance_next_upgrade_time                = try("${network.firmware.upgrade.products.appliance.next_upgrade.local_time}Z", null)
          products_appliance_next_upgrade_to_version_id = try(
            local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)].appliance[try(network.firmware.upgrade.products.appliance.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.appliance.next_upgrade.to_version, "")],
            try(network.firmware.upgrade.products.appliance.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.appliance.next_upgrade.to_version, null)
          )

          products_cellular_gateway_participate_in_next_beta_release = try(network.firmware.upgrade.products.cellular_gateway.participate_in_next_beta_release, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.cellular_gateway.participate_in_next_beta_release, null)
          products_cellular_gateway_next_upgrade_time                = try("${network.firmware.upgrade.products.cellular_gateway.next_upgrade.local_time}Z", null)
          products_cellular_gateway_next_upgrade_to_version_id = try(
            local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)].cellular_gateway[try(network.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, "")],
            try(network.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, null)
          )
          } if(
          try(network.firmware.automatic_upgrade_window, null) != null ||
          try(network.firmware.upgrade, null) != null
        )
      ]
    ]
  ])
}

resource "meraki_network_firmware_upgrades" "networks_firmware_upgrades" {
  for_each   = { for v in local.networks_firmware_upgrades : v.key => v }
  network_id = each.value.network_id

  upgrade_window_day_of_week = each.value.upgrade_window_day_of_week
  upgrade_window_hour_of_day = each.value.upgrade_window_hour_of_day

  products_switch_participate_in_next_beta_release = each.value.products_switch_participate_in_next_beta_release
  products_switch_next_upgrade_time                = each.value.products_switch_next_upgrade_time
  products_switch_next_upgrade_to_version_id       = each.value.products_switch_next_upgrade_to_version_id

  products_switch_catalyst_participate_in_next_beta_release = each.value.products_switch_catalyst_participate_in_next_beta_release
  products_switch_catalyst_next_upgrade_time                = each.value.products_switch_catalyst_next_upgrade_time
  products_switch_catalyst_next_upgrade_to_version_id       = each.value.products_switch_catalyst_next_upgrade_to_version_id

  products_wireless_participate_in_next_beta_release = each.value.products_wireless_participate_in_next_beta_release
  products_wireless_next_upgrade_time                = each.value.products_wireless_next_upgrade_time
  products_wireless_next_upgrade_predownload_enabled = each.value.products_wireless_next_upgrade_predownload_enabled
  products_wireless_next_upgrade_to_version_id       = each.value.products_wireless_next_upgrade_to_version_id

  products_appliance_participate_in_next_beta_release = each.value.products_appliance_participate_in_next_beta_release
  products_appliance_next_upgrade_time                = each.value.products_appliance_next_upgrade_time
  products_appliance_next_upgrade_to_version_id       = each.value.products_appliance_next_upgrade_to_version_id

  products_cellular_gateway_participate_in_next_beta_release = each.value.products_cellular_gateway_participate_in_next_beta_release
  products_cellular_gateway_next_upgrade_time                = each.value.products_cellular_gateway_next_upgrade_time
  products_cellular_gateway_next_upgrade_to_version_id       = each.value.products_cellular_gateway_next_upgrade_to_version_id
}

locals {
  networks_firmware_rollbacks = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for network in try(organization.networks, []) : [
          for product, product_cfg in {
            switch          = try(network.firmware.downgrade.products.switch, null)
            switchCatalyst  = try(network.firmware.downgrade.products.switch_catalyst, null)
            wireless        = try(network.firmware.downgrade.products.wireless, null)
            appliance       = try(network.firmware.downgrade.products.appliance, null)
            cellularGateway = try(network.firmware.downgrade.products.cellular_gateway, null)
            } : {
            key        = format("%s/%s/%s/%s", domain.name, organization.name, network.name, product)
            network_id = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, network.name)]
            product    = product
            time       = try("${product_cfg.next_downgrade.local_time}Z", null)
            to_version_id = try(
              local.networks_firmware_version_maps[format("%s/%s/%s", domain.name, organization.name, network.name)][{
                switch          = "switch"
                switchCatalyst  = "switch_catalyst"
                wireless        = "wireless"
                appliance       = "appliance"
                cellularGateway = "cellular_gateway"
              }[product]][try(product_cfg.next_downgrade.to_version, "")],
              try(product_cfg.next_downgrade.to_version, null)
            )
            predownload_enabled = product == "wireless" ? try(product_cfg.next_downgrade.pre_download, local.defaults.meraki.domains.organizations.networks.firmware.downgrade.products.wireless.next_downgrade.pre_download, null) : null
            reasons = try(product_cfg.next_downgrade.reasons, null) == null ? null : [
              for reason in try(product_cfg.next_downgrade.reasons, []) : {
                category = try(reason.category, null)
                comment  = try(reason.comment, null)
              }
            ]
          } if product_cfg != null
        ] if try(network.firmware.downgrade, null) != null
      ]
    ]
  ])
}

resource "meraki_network_firmware_upgrades_rollback" "networks_firmware_rollbacks" {
  for_each            = { for v in local.networks_firmware_rollbacks : v.key => v }
  network_id          = each.value.network_id
  product             = each.value.product
  time                = each.value.time
  to_version_id       = each.value.to_version_id
  predownload_enabled = each.value.predownload_enabled
  reasons             = each.value.reasons
}
