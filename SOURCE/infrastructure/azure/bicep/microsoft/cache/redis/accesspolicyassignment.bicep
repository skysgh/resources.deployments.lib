// ======================================================================
// Scope
// ======================================================================

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../../settings/shared.json')

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
@description('Name of parent redis cache resource')
param parentResourceName string

@description('Specify name of custom access policy to create. (e.g., \'BuiltInAccessPolicyAssignment\')' )
param resourceName string

/ ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
// N/A

// ======================================================================
// Resource other Params
// ======================================================================

@description('Specify the valid objectId(usually it is a GUID) of the Microsoft Entra Service Principal or Managed Identity or User Principal to which the built-in access policy would be assigned.')
param builtInAccessPolicyAssignmentObjectId string = newGuid()



// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var uniqueString = uniqueString(resourceGroup().id)
var useName = 'builtInAccessPolicyAssignment-${uniqueString}'
//var useLocation = 'n/a'
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' = {
  name: resourceName
  parent: parentResourceName
  properties: {
    accessPolicyName: builtInAccessPolicyName
    objectId: builtInAccessPolicyAssignmentObjectId
    objectIdAlias: builtInAccessPolicyAssignmentObjectAlias
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
