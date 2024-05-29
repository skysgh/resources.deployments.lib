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


// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
// Resources Groups are part of the general subscription
@description('The project name. This informs automation of naming of resource groups, services, etc. e.g.: \'BASE\'')
@maxLength(11) // Limited by storageAccount name length (24) minus 13 chars for uniqueString(...)
param projectName string

@description('The project service name. Name used to build resources. e.g.: \'SERVICE\'')
param projectServiceName string = 'SERVICE'

@allowed (['NP','BT', 'DT','ST','UT','IT','TR','PP','PR'])
param environmentId string
// ======================================================================
@description('The location of the parent resource group. ')
// @allowed(...too long...)
param resourceGroupLocationId string

@description('The default location of resources. Default: set to \'resourceGroupLocationId\'.')
// @allowed(...too long...)
param resourceLocationId string = resourceGroupLocationId

@description('The tags for this resource. ')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
@description('Resource SKU. Default is \'Standard_LRS\' (Standard Locally Redundant Storage). Other options are GLobally redundant (Standard_GRS), Zone Redundant(Standard_ZRS), etc..')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountsSKU string = 'Standard_LRS' 

// ======================================================================
// Resource other Params
// ======================================================================
@description('The location of the parent resource group. Default: set to resourceLocationId')
// @allowed(...too long...)
param storageAccountsLocationId string = resourceLocationId 


// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var tmp = empty(projectServiceName) ? '_':'_${projectServiceName}_'
var fullName = '${projectName}${tmp}${environmentId}' 
var shortName = projectName
// Note that I couldn't get resourceGroup().id so switching to subscription
var uniqueSuffix = uniqueString(subscription().subscriptionId)
var groupResourceName =  toUpper(sharedSettings.namingConventions.parentNameIsLonger ?  fullName : shortName)
var parentResourceName = toUpper(sharedSettings.namingConventions.parentNameIsLonger ? fullName : shortName)
var childResourceName =  toUpper(sharedSettings.namingConventions.parentNameIsLonger ? shortName : fullName)
var defaultTags = {project: projectName, service: projectServiceName, environment: environmentId}

// 24-14 = 10
// "base_kgxkbwfgeorz6 is not a valid storage account name. Storage account name must be between 3 and 24
var useResourceGroupName = groupResourceName
// Storage Resource Name: minLengh:3, maxLength:4, lowercase, alphanumeric, no dashes or underlines.
var useName = toLower(replace(replace('${childResourceName}${uniqueSuffix}', '-', ''),'_','') )
var useLocation = storageAccountsLocationId
var useTags = union(resourceTags, defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
module resourceGroupsModule '../microsoft/resources/resourcegroups.bicep' = if (buildResource) {
  name:  '${deployment().name}_resourcegroups_module'
  scope: subscription()
  params: {
    resourceName: useResourceGroupName
    resourceLocationId: resourceGroupLocationId
    resourceTags: useTags
  }
}
// ------------------------------------------------------------
module storageAccountsModule '../microsoft/storage/storageaccounts.bicep' = if (buildResource) {
  // should be implied: 
  dependsOn: [resourceGroupsModule]
  name:  '${deployment().name}_storageaccounts_module'
  scope: resourceGroup(useResourceGroupName) 
  params: {
    resourceName: useName
    resourceLocationId: useLocation
    resourceTags: useTags

    resourceSKU: storageAccountsSKU
  }
}
// ------------------------------------------------------------






// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================
// Provide ref to (key) developed resource:
// output resource object = storageAccountsModule.outputs.resource
output resourceId string = storageAccountsModule.outputs.resourceId
output resourceName string = storageAccountsModule.outputs.resourceName
// param sink (to not cause error if param is not used):
output _ bool = startsWith('${sharedSettings.version}-${resourceLocationId}-${uniqueSuffix}-${parentResourceName}', '.')
