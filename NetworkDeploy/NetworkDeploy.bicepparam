using './NetworkDeploy.bicep'

param localIP = getSecret('79d60d7a-094d-4008-bf79-f4328565faea', 'VmFleetRG', 'VmFleetKV', 'LocalIp')

