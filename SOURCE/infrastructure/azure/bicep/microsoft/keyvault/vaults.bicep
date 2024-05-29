// ======================================================================
// References
// ======================================================================
// https://learn.microsoft.com/en-us/azure/key-vault/keys/quick-create-template?tabs=CLI

// ======================================================================
// Scope
// ======================================================================
// Resources are part of a parent resource group:
targetScope='resourceGroup'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../settings/shared.json')

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
@description('Specifies the name of the key vault resource.')
param resourceName string

@description('Specifies the Azure location where the key vault should be created.')
param resourceLocationId string = resourceGroup().location

@description('Resource tags')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
@description('SKU of keyvault. Default is \'standard\' - not \'premium\'')
@allowed([
  'standard'
  'premium'
])
param resourceSKU string = 'standard' // not permitted to invoke now :-( shared.standardSKUs.keyVault


@allowed([
  'A'
])
param resourceFamily string = 'A'
// ======================================================================
// Resource other Params
// ======================================================================
@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param tenantObjectId string

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'list'
]

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = keyValueName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.KeyVault/vaults@2023-07-01' = if (buildResource) {
  name: useName
  location: useLocation
  tags: useTags

  properties: {

    sku: {
      name: resourceSKU
      family: resourceFamily
    }

    // accessPolicies: []
    // enableRBacAuthorization: true

    enableSoftDelete: true
    softDeleteRetentionInDays: 90

    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    
    tenantId: tenantId


    accessPolicies: [
      {
        objectId: tenantObjectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================
// Provide ref to developed resource:
output resource object = resource
// return the id (the fully qualitified name) of the newly created resource:
output resourceId string = resource.id
// return the (short) name of the newly created resource:
output resourceName string = resource.name
// param sink (to not cause error if param is not used):
output _ bool = startsWith(concat('${sharedSettings.version}'), '.')
