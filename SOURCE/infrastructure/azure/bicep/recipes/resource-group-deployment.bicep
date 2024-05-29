// ======================================================================
// Resources
// ======================================================================
// https://blog.robsewell.com/blog/flexing-my-bicep-deploy-an-azure-sql-database-intro-to-azure-bicep-iac/

// ======================================================================
// Scope
// ======================================================================
//targetScope='resourceGroup'// NO: it stops resourceGroup().location from working: 'subscription'
targetScope='subscription'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../settings/shared.json')


// ======================================================================
// Flow Control
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Parent Resource Group  
// ======================================================================
@description('The name of the resource group in which to create these resources. ')
@minLength(3)
param resourceGroupName string

@description('The lowercase identifier of where to build the resource Group. Default is \'australiacentral\'.')
//TooBig @allowed([ 'australiacentral'])
param resourceGroupLocationId string

@description('The tags for this resource. ')
param resourceGroupTags object = {}







// ======================================================================
// Resource bicep
// ======================================================================
module resourceGroupsModule '../microsoft/resources/resourcegroups.bicep' = if (buildResource) {
  name:  '${deployment().name}_resourcegroups_module'
  scope: subscription()
  params: {
    resourceName: resourceGroupName
    resourceLocationId: resourceGroupLocationId
    resourceTags: union(sharedSettings.defaultTags, resourceGroupTags)
  }
}
// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================
output resourceId string = resourceGroupModule.outputs.resourceId
output resourceName string = resourceGroupModule.outputs.resourceName
output resourceUniqueString string = resourceGroupModule.outputs.resourceUniqueString
