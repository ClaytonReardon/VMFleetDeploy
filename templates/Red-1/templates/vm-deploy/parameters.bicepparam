using 'template.bicep'

param location = 'westus'

param networkInterfaceName = 'red-1155'

param networkSecurityGroupName = 'Red-1-nsg'

param networkSecurityGroupRules = [
  {
    name: 'default-allow-ssh'
    properties: {
      priority: 100
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '47.156.162.79'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '22'
    }
  }
  {
    name: 'DenyAll'
    properties: {
      priority: 1010
      protocol: '*'
      access: 'Deny'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
    }
  }
  {
    name: 'AllowICMP'
    properties: {
      priority: 200
      protocol: 'ICMP'
      access: 'Allow'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '47.156.162.79'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
    }
  }
  {
    name: 'AllowSSH'
    properties: {
      priority: 100
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Outbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '47.156.162.79'
      destinationPortRange: '*'
    }
  }
  {
    name: 'AllowICMPOut'
    properties: {
      priority: 200
      protocol: 'ICMP'
      access: 'Deny'
      direction: 'Outbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '47.156.162.79'
      destinationPortRange: '*'
    }
  }
  {
    name: 'DenyAllOut'
    properties: {
      priority: 1000
      protocol: '*'
      access: 'Deny'
      direction: 'Outbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
    }
  }
]

param subnetName = 'Red-1-Subnet'

param virtualNetworkId = '/subscriptions/79d60d7a-094d-4008-bf79-f4328565faea/resourceGroups/VmFleetRG/providers/Microsoft.Network/virtualNetworks/VmFleetVnet'

param publicIpAddressName = 'Red-1-ip'

param publicIpAddressType = 'Static'

param publicIpAddressSku = 'Standard'

param pipDeleteOption = 'Detach'

param virtualMachineName = 'Red-1'

param virtualMachineComputerName = 'Red-1'

param virtualMachineRG = 'VmFleetRG'

param osDiskType = 'StandardSSD_LRS'

param osDiskDeleteOption = 'Delete'

param virtualMachineSize = 'Standard_B1s'

param nicDeleteOption = 'Detach'

param hibernationEnabled = false

param adminUsername = 'red1'

param securityType = 'TrustedLaunch'

param secureBoot = true

param vTPM = true
