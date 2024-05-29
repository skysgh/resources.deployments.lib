// ======================================================================
// Scope
// ======================================================================
// https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/secrets?pivots=deployment-language-bicep

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../../settings/shared.json')

// Resources are part of a parent resource group:
targetScope='resourceGroup'

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// 
// ======================================================================
@description('Name of parent Resource - a keyvault')
param parentResource string

@description('Build the resoure. For testing, can be set to false').
param buildResource bool = true

//@description('Resource Name')
//param resourceName string

@description('Resource Tags. N/A')
param resourceTags object = {}
// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================


// ======================================================================
// Resource other Params
// ======================================================================
@description('key of secret')
param key string

@description('string value of secret')
@secure
param secret string 

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = 'n/a'
var useTags = union(resourceTags, sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (buildResource) {
  parent: parentResource
  name: resourceName
  tags: useTags
  properties: {
    attributes: {  
      enabled:true
      // exp:int
      // nbf:int
    }
    value: secret
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
