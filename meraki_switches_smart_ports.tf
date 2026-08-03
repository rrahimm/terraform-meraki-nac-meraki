##
## SmartPorts — Organization-level port profiles and automation rules
## API: /organizations/{organizationId}/switch/ports/profiles (Beta)
##      /organizations/{organizationId}/switch/ports/profiles/automations (Beta)
##

# ---------------------------------------------------------------------------
# Switch Port Profiles
# ---------------------------------------------------------------------------

locals {
  organizations_switch_port_profiles = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for profile in try(organization.switch_port_profiles, []) : {
          key                  = format("%s/%s/%s", domain.name, organization.name, profile.name)
          organization_id      = local.organization_ids[format("%s/%s", domain.name, organization.name)]
          name                 = try(profile.name, local.defaults.meraki.domains.organizations.switch_port_profiles.name, null)
          description          = try(profile.description, local.defaults.meraki.domains.organizations.switch_port_profiles.description, null)
          is_organization_wide = try(profile.is_organization_wide, local.defaults.meraki.domains.organizations.switch_port_profiles.is_organization_wide, null)
          networks_type        = try(profile.networks_type, local.defaults.meraki.domains.organizations.switch_port_profiles.networks_type, null)
          networks = try(profile.networks, null) == null ? null : [
            for net_name in try(profile.networks, []) : {
              id   = local.organizations_network_ids[format("%s/%s/%s", domain.name, organization.name, net_name)]
              name = net_name
            }
          ]
          port_type                        = try(profile.port_type, local.defaults.meraki.domains.organizations.switch_port_profiles.port_type, null)
          port_vlan                        = try(profile.port_vlan, local.defaults.meraki.domains.organizations.switch_port_profiles.port_vlan, null)
          port_voice_vlan                  = try(profile.port_voice_vlan, local.defaults.meraki.domains.organizations.switch_port_profiles.port_voice_vlan, null)
          port_allowed_vlans               = try(profile.port_allowed_vlans, local.defaults.meraki.domains.organizations.switch_port_profiles.port_allowed_vlans, null)
          port_access_policy_type          = try(profile.port_access_policy_type, local.defaults.meraki.domains.organizations.switch_port_profiles.port_access_policy_type, null)
          port_access_policy_number        = try(meraki_switch_access_policy.networks_switch_access_policies[format("%s/%s/%s/%s", domain.name, organization.name, profile.networks[0], profile.port_access_policy_name)].id, null)
          port_mac_allow_list              = try(profile.port_mac_allow_list, local.defaults.meraki.domains.organizations.switch_port_profiles.port_mac_allow_list, null)
          port_sticky_mac_allow_list       = try(profile.port_sticky_mac_allow_list, local.defaults.meraki.domains.organizations.switch_port_profiles.port_sticky_mac_allow_list, null)
          port_sticky_mac_allow_list_limit = try(profile.port_sticky_mac_allow_list_limit, local.defaults.meraki.domains.organizations.switch_port_profiles.port_sticky_mac_allow_list_limit, null)
          port_poe_enabled                 = try(profile.port_poe, local.defaults.meraki.domains.organizations.switch_port_profiles.port_poe, null)
          port_isolation_enabled           = try(profile.port_isolation, local.defaults.meraki.domains.organizations.switch_port_profiles.port_isolation, null)
          port_rstp_enabled                = try(profile.port_rstp, local.defaults.meraki.domains.organizations.switch_port_profiles.port_rstp, null)
          port_stp_guard                   = try(profile.port_stp_guard, local.defaults.meraki.domains.organizations.switch_port_profiles.port_stp_guard, null)
          port_udld                        = try(profile.port_udld, local.defaults.meraki.domains.organizations.switch_port_profiles.port_udld, null)
          port_storm_control_enabled       = try(profile.port_storm_control, local.defaults.meraki.domains.organizations.switch_port_profiles.port_storm_control, null)
          port_dai_trusted                 = try(profile.port_dai_trusted, local.defaults.meraki.domains.organizations.switch_port_profiles.port_dai_trusted, null)
          port_peer_sgt_capable            = try(profile.port_peer_sgt_capable, local.defaults.meraki.domains.organizations.switch_port_profiles.port_peer_sgt_capable, null)
          authentication_host_mode         = try(profile.authentication_host_mode, local.defaults.meraki.domains.organizations.switch_port_profiles.authentication_host_mode, null)
        }
      ]
    ]
  ])
}

resource "meraki_switch_organization_ports_profile" "organizations_switch_port_profiles" {
  for_each                         = { for v in local.organizations_switch_port_profiles : v.key => v }
  organization_id                  = each.value.organization_id
  name                             = each.value.name
  description                      = each.value.description
  is_organization_wide             = each.value.is_organization_wide
  networks_type                    = each.value.networks_type
  networks                         = each.value.networks
  port_type                        = each.value.port_type
  port_vlan                        = each.value.port_vlan
  port_voice_vlan                  = each.value.port_voice_vlan
  port_allowed_vlans               = each.value.port_allowed_vlans
  port_access_policy_type          = each.value.port_access_policy_type
  port_access_policy_number        = each.value.port_access_policy_number
  port_mac_allow_list              = each.value.port_mac_allow_list
  port_sticky_mac_allow_list       = each.value.port_sticky_mac_allow_list
  port_sticky_mac_allow_list_limit = each.value.port_sticky_mac_allow_list_limit
  port_poe_enabled                 = each.value.port_poe_enabled
  port_isolation_enabled           = each.value.port_isolation_enabled
  port_rstp_enabled                = each.value.port_rstp_enabled
  port_stp_guard                   = each.value.port_stp_guard
  port_udld                        = each.value.port_udld
  port_storm_control_enabled       = each.value.port_storm_control_enabled
  port_dai_trusted                 = each.value.port_dai_trusted
  port_peer_sgt_capable            = each.value.port_peer_sgt_capable
  authentication_host_mode         = each.value.authentication_host_mode
}

locals {
  organizations_switch_port_profile_ids = {
    for v in local.organizations_switch_port_profiles :
    v.key => meraki_switch_organization_ports_profile.organizations_switch_port_profiles[v.key].id
  }
}

# ---------------------------------------------------------------------------
# Switch Port Profile Automations
# ---------------------------------------------------------------------------

locals {
  organizations_switch_port_profiles_automations = flatten([
    for domain in try(local.meraki.domains, []) : [
      for organization in try(domain.organizations, []) : [
        for automation in try(organization.switch_port_profiles_automations, []) : {
          key                   = format("%s/%s/%s", domain.name, organization.name, automation.name)
          organization_id       = local.organization_ids[format("%s/%s", domain.name, organization.name)]
          name                  = try(automation.name, local.defaults.meraki.domains.organizations.switch_port_profiles_automations.name, null)
          description           = try(automation.description, local.defaults.meraki.domains.organizations.switch_port_profiles_automations.description, null)
          fallback_profile_id   = try(local.organizations_switch_port_profile_ids[format("%s/%s/%s", domain.name, organization.name, automation.fallback_profile_name)], null)
          fallback_profile_name = try(automation.fallback_profile_name, local.defaults.meraki.domains.organizations.switch_port_profiles_automations.fallback_profile_name, null)
          assigned_switch_ports = try(automation.assigned_switch_ports, null) == null ? null : [
            for asp in try(automation.assigned_switch_ports, []) : {
              switch_serial = meraki_device.devices[format("%s/%s/%s/%s", domain.name, organization.name, asp.network, asp.switch)].serial
              port_ids = flatten([
                for r in asp.port_id_ranges : [
                  for port_id in range(r.from, r.to + 1) :
                  try(r.slot, null) != null && try(r.module, null) != null
                  ? format("%s_%s_%s", r.slot, r.module, port_id)
                  : port_id
                ]
              ])
            }
          ]
          rules = [
            for rule in try(automation.rules, []) : {
              priority     = rule.priority
              profile_id   = local.organizations_switch_port_profile_ids[format("%s/%s/%s", domain.name, organization.name, rule.profile_name)]
              profile_name = rule.profile_name
              conditions = [
                for condition in try(rule.conditions, []) : {
                  attribute = condition.attribute
                  values    = condition.values
                }
              ]
            }
          ]
        }
      ]
    ]
  ])
}

resource "meraki_switch_organization_ports_profiles_automation" "organizations_switch_port_profiles_automations" {
  for_each              = { for v in local.organizations_switch_port_profiles_automations : v.key => v }
  organization_id       = each.value.organization_id
  name                  = each.value.name
  description           = each.value.description
  fallback_profile_id   = each.value.fallback_profile_id
  fallback_profile_name = each.value.fallback_profile_name
  assigned_switch_ports = each.value.assigned_switch_ports
  rules                 = each.value.rules

  depends_on = [
    meraki_switch_organization_ports_profile.organizations_switch_port_profiles,
  ]
}
