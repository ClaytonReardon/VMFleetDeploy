param vmName string
param adminUsername string
@secure()
param adminPasswordOrKey string
@secure()
param localIP string
param domainNameLabel string = uniqueString(vmName, resourceGroup().id)
param location string = resourceGroup().location
param vmSize string = 'Standard_B1ls'
param vnetName string = 'VmFleetVnet'
param subnetName string = ('${vmName}Subnet')
param nsgName string = 'VmFleetNSG'
param subnetAddressPrefix string

var publicIPId = resourceId('Microsoft.Network/publicIPAddresses', publicIPAddressName)
var publicIPAddressName = '${vmName}PublicIP'
var nsgId = resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
var nicName = '${vmName}Nic'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
var osDiskType = 'Standard_LRS'
var vnetAddressPrefix = '10.10.0.0/16'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshIn'
        properties: {
          priority: 100
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: localIP
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'AllowIcmpIn'
        properties: {
          priority: 200
          protocol: 'ICMP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: localIP
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'DenyAllIn'
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
        name: 'AllowIcmpOut'
        properties: {
          priority: 200
          protocol: 'ICMP'
          access: 'Deny'
          direction: 'Outbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: localIP
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
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
    idleTimeoutInMinutes: 5
  }
  sku: {
    name: 'Basic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPId
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    virtualNetwork
    publicIPAddress
  ]
}


resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'debian'
        offer: 'debian-11'
        sku: '11-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: linuxConfiguration
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output administratorUsername string = adminUsername
