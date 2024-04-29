var vmName = 'Purple4'
param adminUsername string = 'Purple4'
@secure()
param sshPublicKey string
@secure()
param storageAccountName string
@secure()
param storageAccountKey string
var vnetName  = 'VmFleetVnet'
var subnetName = '${vmName}Subnet'
var subnetAddressPrefix = '10.10.4.0/24'
param location string = resourceGroup().location
var publicIPAddressName = '${vmName}PublicIP'
var unique = uniqueString(vmName, resourceGroup().id)
var domainNameLabel = '${toLower(vmName)}-${replace(toLower(unique), '-', '')}'
var nicName = '${vmName}Nic'
var nsgName = 'VmFleetNSG'
var nsgId = resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
var vmSize = 'Standard_B1ls'
var osDiskType = 'Standard_LRS'
var storageEndpointSuffix = environment().suffixes.storage // Uses `environment()` to get appropriate domain suffix based on environment
var scriptContainer = 'vmscripts'
var scriptBlobName = 'Purple4Script.sh'
var scriptUrl = 'https://${storageAccountName}.blob.${storageEndpointSuffix}/${scriptContainer}/${scriptBlobName}'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ]
  }
}


resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: existingVnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
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
            id: publicIPAddress.id
          }
          subnet: {
            id: subnet.id
        }
      }
    }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
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

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: virtualMachine
  name: 'CustomScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptUrl
      ]
      commandToExecute: 'bash ${scriptBlobName}'
    }
    protectedSettings: {
      storageAccountName: storageAccountName
      storageAccountKey: storageAccountKey
    }
  }
}

output administratorUsername string = adminUsername
