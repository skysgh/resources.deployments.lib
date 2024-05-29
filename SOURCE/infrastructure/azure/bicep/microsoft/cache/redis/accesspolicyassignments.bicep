// ======================================================================
// Scope
// ======================================================================

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../settings/shared.json')

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
@description('The parent resoure cache.')
param parentResource object

@description('The previous related redis cache custom AccessPolicy.')
param previousResource object

@description('Policy Assignment name')
param resourceName string = '+@connection +get +hget allkeys'

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================

// ======================================================================
// Resource other Params
// ======================================================================
@description('Policy Assignment id')
param accessPolicyName string;

@description('Policy Assignment id')
param objectId string = newGuid()

@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for custom policy assignment.')
param objectIdAlias string = 'customAccessPolicyApplication-${uniqueString(resourceGroup().id)}'


@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for custom policy assignment.')
param customAccessPolicyAssignmentObjectAlias string = 'customAccessPolicyApplication-${uniqueString(resourceGroup().id)}'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
// Develop default variables.
var useName = resourceName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' = {
  parent: parentResource // the redis cache

  name: useName
  tags: useTags

  properties: {
    accessPolicyName: accessPolicyName
    objectId: objectId
    objectIdAlias: objectIdAlias
  }
  dependsOn: [
    previousResource
  ]
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
