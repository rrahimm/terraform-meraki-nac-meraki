locals {
  networks_firmware_upgrades = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for network in try(organization.networks, []) : {
          key        = format("%s/%s/%s", domain.name, organization.name, network.name)
          network_id = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, network.name)]

          timezone                   = try(network.firmware.timezone, local.defaults.meraki.domains.organizations.networks.firmware.timezone, null)
          upgrade_window_day_of_week = try(network.firmware.automatic_upgrade_window.day_of_week, local.defaults.meraki.domains.organizations.networks.firmware.automatic_upgrade_window.day_of_week, null)
          upgrade_window_hour_of_day = try(network.firmware.automatic_upgrade_window.hour_of_day, local.defaults.meraki.domains.organizations.networks.firmware.automatic_upgrade_window.hour_of_day, null)

          products_switch_next_upgrade_time          = try(network.firmware.upgrade.products.switch.next_upgrade.local_time, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch.next_upgrade.local_time, null)
          products_switch_next_upgrade_to_version_id = try(network.firmware.upgrade.products.switch.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch.next_upgrade.to_version, null)

          products_switch_catalyst_next_upgrade_time          = try(network.firmware.upgrade.products.switch_catalyst.next_upgrade.local_time, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch_catalyst.next_upgrade.local_time, null)
          products_switch_catalyst_next_upgrade_to_version_id = try(network.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.switch_catalyst.next_upgrade.to_version, null)

          products_wireless_next_upgrade_time                = try(network.firmware.upgrade.products.wireless.next_upgrade.local_time, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.local_time, null)
          products_wireless_next_upgrade_to_version_id       = try(network.firmware.upgrade.products.wireless.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.to_version, null)
          products_wireless_next_upgrade_prepare_for_upgrade = try(network.firmware.upgrade.products.wireless.next_upgrade.pre_download, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.wireless.next_upgrade.pre_download, null)

          products_appliance_next_upgrade_time          = try(network.firmware.upgrade.products.appliance.next_upgrade.local_time, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.appliance.next_upgrade.local_time, null)
          products_appliance_next_upgrade_to_version_id = try(network.firmware.upgrade.products.appliance.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.appliance.next_upgrade.to_version, null)

          products_cellular_gateway_next_upgrade_time          = try(network.firmware.upgrade.products.cellular_gateway.next_upgrade.local_time, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.cellular_gateway.next_upgrade.local_time, null)
          products_cellular_gateway_next_upgrade_to_version_id = try(network.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, local.defaults.meraki.domains.organizations.networks.firmware.upgrade.products.cellular_gateway.next_upgrade.to_version, null)
        } if try(network.firmware, null) != null
      ]
    ]
  ])
}

resource "meraki_network_firmware_upgrades" "networks_firmware_upgrades" {
  for_each   = { for v in local.networks_firmware_upgrades : v.key => v }
  network_id = each.value.network_id

  timezone                   = each.value.timezone
  upgrade_window_day_of_week = each.value.upgrade_window_day_of_week
  upgrade_window_hour_of_day = each.value.upgrade_window_hour_of_day

  products_switch_next_upgrade_time          = each.value.products_switch_next_upgrade_time
  products_switch_next_upgrade_to_version_id = each.value.products_switch_next_upgrade_to_version_id

  products_switch_catalyst_next_upgrade_time          = each.value.products_switch_catalyst_next_upgrade_time
  products_switch_catalyst_next_upgrade_to_version_id = each.value.products_switch_catalyst_next_upgrade_to_version_id

  products_wireless_next_upgrade_time                = each.value.products_wireless_next_upgrade_time
  products_wireless_next_upgrade_to_version_id       = each.value.products_wireless_next_upgrade_to_version_id
  products_wireless_next_upgrade_prepare_for_upgrade = each.value.products_wireless_next_upgrade_prepare_for_upgrade

  products_appliance_next_upgrade_time          = each.value.products_appliance_next_upgrade_time
  products_appliance_next_upgrade_to_version_id = each.value.products_appliance_next_upgrade_to_version_id

  products_cellular_gateway_next_upgrade_time          = each.value.products_cellular_gateway_next_upgrade_time
  products_cellular_gateway_next_upgrade_to_version_id = each.value.products_cellular_gateway_next_upgrade_to_version_id
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
            key           = format("%s/%s/%s/%s", domain.name, organization.name, network.name, product)
            network_id    = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, network.name)]
            product       = product
            time          = try(product_cfg.next_downgrade.local_time, null)
            to_version_id = try(product_cfg.next_downgrade.to_version, null)
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
  for_each      = { for v in local.networks_firmware_rollbacks : v.key => v }
  network_id    = each.value.network_id
  product       = each.value.product
  time          = each.value.time
  to_version_id = each.value.to_version_id
  reasons       = each.value.reasons
}
