using './Purple4Deploy.bicep'

param sshPublicKey = getSecret('79d60d7a-094d-4008-bf79-f4328565faea', 'VmFleetRG', 'VmFleetKV', 'SSh-Public-Key')
param storageAccountName = getSecret('79d60d7a-094d-4008-bf79-f4328565faea', 'VmFleetRG', 'VmFleetKV', 'storageAccountName')
param storageAccountKey = getSecret('79d60d7a-094d-4008-bf79-f4328565faea', 'VmFleetRG', 'VmFleetKV', 'storageAccountKey')

