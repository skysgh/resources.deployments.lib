// ======================================================================
// Resources
// ======================================================================
// https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-redis-cache-bicep-provision?tabs=CLI

// ======================================================================
// Scope
// ======================================================================
targetScope='subscription'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../settings/shared.json')

// ======================================================================
// Flow Control
// ======================================================================
// Resources Groups are part of the general subscription
@description('Whether to build the ResourceGroup or not.')
param buildResourceGroup bool = true

@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
@description('resourceName')
@minLength(3)
@maxLength(22)
param resourceName string

@description('Deployment Location')
// Too long: @allowed(['westeurope''northeurope'])
param resourceLocationId string

@description('Resource Tags. Note: will be merged with the imported sharedTags.defaultTags.')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier, Family, Capacity where applicable
// ======================================================================
@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param resourceSKU string = 'Standard'

@description('Specify the family for the SKU. C = Basic/Standard, P = Premium.')
@allowed([
  'C'
  'P'
])
param resourceFamily string = 'C'

@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4, 5)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param resourceCapacity int = 1




@description('Specify name of Built-In access policy to use as assignment.')
@allowed([
  'Data Owner'
  'Data Contributor'
  'Data Reader'
])
param builtInAccessPolicyName string = 'Data Reader'

@description('Specify name of custom access policy to create.')
param builtInAccessPolicyAssignmentName string = 'builtInAccessPolicyAssignment-${uniqueString(resourceGroup().id)}'

@description('Specify the valid objectId(usually it is a GUID) of the Microsoft Entra Service Principal or Managed Identity or User Principal to which the built-in access policy would be assigned.')
param builtInAccessPolicyAssignmentObjectId string = newGuid()

@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for built-in policy assignment.')
param builtInAccessPolicyAssignmentObjectAlias string = 'builtInAccessPolicyApplication-${uniqueString(resourceGroup().id)}'

@description('Specify name of custom access policy to create.')
param customAccessPolicyName string = 'customAccessPolicy-${uniqueString(resourceGroup().id)}'

@description('Specify the valid permissions for the customer access policy to create. For details refer to https://aka.ms/redis/ConfigureAccessPolicyPermissions')
param customAccessPolicyPermissions string = '+@connection +get +hget allkeys'

@description('Specify name of custom access policy to create.')
param customAccessPolicyAssignmentName string = 'customAccessPolicyAssignment-${uniqueString(resourceGroup().id)}'

@description('Specify the valid objectId(usually it is a GUID) of the Microsoft Entra Service Principal or Managed Identity or User Principal to which the custom access policy would be assigned.')
param customAccessPolicyAssignmentObjectId string = newGuid()

@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for custom policy assignment.')
param customAccessPolicyAssignmentObjectAlias string = 'customAccessPolicyApplication-${uniqueString(resourceGroup().id)}'


// ======================================================================
// Resource other Params
// ======================================================================


// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
// Develop default variables.
var useName = toLower(resourceName)
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)
var uniqueString = uniqueString(resourceGroup().id)

var useName = 'redisCache-${uniqueString}'

// ======================================================================
// Resource bicep
// ======================================================================
resource redisCache 'Microsoft.Cache/redis@2023-08-01' = if (buildResource) {
  name: useName
  location: useLcoation
  properties: {
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    sku: {
      family: resourceFamily
      name: resourceSKU
      capacity: resourceCapacity
    }
    redisConfiguration: {
      'aad-enabled': 'true'
    }
  }
}
// ======================================================================
resource redisCacheBuiltInAccessPolicyAssignment 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' if (buildResource) = {
  name: builtInAccessPolicyAssignmentName
  parent: redisCache
  properties: {
    accessPolicyName: builtInAccessPolicyName
    objectId: builtInAccessPolicyAssignmentObjectId
    objectIdAlias: builtInAccessPolicyAssignmentObjectAlias
  }
}
// ======================================================================
resource redisCacheCustomAccessPolicy 'Microsoft.Cache/redis/accessPolicies@2023-08-01' if (buildResource) = {
  name: customAccessPolicyName
  parent: redisCache
  properties: {
    permissions: customAccessPolicyPermissions
  }
  dependsOn: [
    redisCacheBuiltInAccessPolicyAssignment
  ]
}
// ======================================================================
resource redisCacheCustomAccessPolicyAssignment 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' if (buildResource) = {
  name: customAccessPolicyAssignmentName
  parent: redisCache
  properties: {
    accessPolicyName: customAccessPolicyName
    objectId: customAccessPolicyAssignmentObjectId
    objectIdAlias: customAccessPolicyAssignmentObjectAlias
  }
  dependsOn: [
    redisCacheCustomAccessPolicy
  ]
}



// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================
// Provide ref to developed resource:
output resource object = xxx.outputs.resource
// return the id (the fully qualitified name) of the newly created resource:
output resourceId string = resource.id
// return the (short) name of the newly created resource:
output resourceName string = resource.name
// param sink (to not cause error if param is not used):
output _ bool = startsWith(concat('${sharedSettings.version}'), '.')
