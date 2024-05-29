// ======================================================================
// Scope
// ======================================================================

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../settings/shared.json')


// ======================================================================
// Dependencies
// ======================================================================
@description('previous accessPolicyAssignment outputs.resource object')
param parentResource object

@description('resourceName of parent Redis Cache')
@minLength(3)
@maxLength(22)
param parentResourceName string

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================

@description('resourceName')
@minLength(3)
@maxLength(22)
param resourceName string

// @description('Deployment Location')
// // Too long: @allowed(['westeurope''northeurope'])
// param resourceLocationId string

@description('Resource Tags. Note: will be merged with the imported sharedTags.defaultTags.')
param resourceTags object = {}

// ======================================================================
// Resource other Params
// ======================================================================

description('Specify the valid permissions for the customer access policy to create. For details refer to https://aka.ms/redis/ConfigureAccessPolicyPermissions')
param permissions string = '+@connection +get +hget allkeys'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
// Develop default variables.
var useName = toLower(resourceName)
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

resource resource 'Microsoft.Cache/redis/accessPolicies@2023-08-01' = {

dependsOn: [
    // May require this object to be described at startup.
    parentResource
  ]

name: resourceName
  parent: parentResourceName
  tags: useTags

  properties: {
    permissions: permissions
  }
}
