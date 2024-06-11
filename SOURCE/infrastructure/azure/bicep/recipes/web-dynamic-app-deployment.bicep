// ======================================================================
// Scope
// ======================================================================
//targetScope='resourceGroup'// NO: it stops resourceGroup().location from working: 'subscription'
// NO. It stops resourceLocation().location from working:
// targetScope='subscription'
// NO:targetScope='resourceGroup'
targetScope='subscription'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../settings/shared.json')

// ======================================================================
// Parent Resource Group
// ======================================================================
@description('The name of the parent resource group in which to create these resources. ')
@minLength(3)
param resourceGroupName string


// ======================================================================
// Flow Control
// ======================================================================
// Resources Groups are part of the general subscription
@description('Whether to build the ResourceGroup or not.')
param buildResourceGroup bool = true

@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Settings
// ======================================================================
@description('The default name of resources.')
@minLength(3)
param defaultResourceName string

@description('The default suffix of resouces, appended to defaultResourceName.')
param defaultResourceNameSuffix string = uniqueString(toUpper(resourceGroupName))

@description('The default location of resources. ')
// @allowed(...too long...)
param defaultResourceLocationId string

@description('The tags for this resource. ')
param defaultResourceTags object = {}
// ======================================================================
// Params: Server Farm
// ======================================================================
@description('The name of the serverFarm to which site is deployed. Required to be universally unique (\'defaultResourceNameSuffix\' will be appended later)')
param webServerFarmsResourceName string = toLower(defaultResourceName)

@description('The location of the serverFarm.')
// @allowed(...too long...)
param webServerFarmsResourceLocationId string  = toLower(defaultResourceLocationId)

@description('The web app service plan SKU. Options are: F1,D1,B1,B2,S1,S2. Default: D1 (as F1 can only be used once, and hence needs monitoring).')
@allowed(['F1','D1','B1','B2','S1','S2'])
param webServerFarmsResourceSKU string = 'D1'

@description('The tags for this resource.')
param webServerFarmsResourceTags object = defaultResourceTags
// ======================================================================
// Params: Sites
// ======================================================================
@description('The Name of the site on the server farm. Does not need to be universally unique.')
param webSitesResourceName string = toLower(defaultResourceName)

@description('The location of the site. Default is same as server farm.')
param webSitesResourceLocationId string = toLower(webServerFarmsResourceLocationId)

@description('The tags for this resource.')
param webSitesResourceTags object = defaultResourceTags

@description('Whether to only allow https. Should be true.')
param webSitesHttpOnly bool = true

@description('The type of identity. Default is \'SystemAssigned\' which means creation of *slot specific* Entra Managed Id, that is picked up by outputs at bottom.')
@allowed(['None', 'SystemAssigned', 'SystemAssigned, UserAssigned', 'UserAssigned'])
param webSitesIdentityType string  = 'SystemAssigned'

@description('The Function eXtension to define the runtime stack. Default is \'DOTNETCORE|Latest\' but best be specific to not get caught out if .net.core releases a version that you are in compatible with.')
@allowed(['DOTNETCORE|8.0','DOTNETCORE|LTS','DOTNETCORE|Latest'])
param webSitesLinuxFxVersion string


// ======================================================================
// Params: Web Sites SourceControl
// ======================================================================
@description('The Name of the site on the server farm. Unlike Server Farms, must be globally unique, so later will be appended with \'defaultResourceNameSuffix\'.')
param webSitesSourceControlsResourceName string = toLower(webSitesResourceName)

@description('The location of the site. Default is same as server farm.')
param webSitesSourceControlsResourceLocationId string = toLower(webSitesResourceLocationId)

@description('The tags for this resource.')
param webSitesSourceControlsResourceTags object = defaultResourceTags

@description('The url to the repository to be deployed to the Server. Default is empty string (\'\'). ')
param webSitesSourceControlsRepositoryUrl string = ''

@description('The repositoryToken if repositoryUrl is set. Default is empty string (\'\').')
@secure()
param webSitesSourceControlsRepositoryToken string = ''

@description('The branch of the repository to use. TODO: this should depend on what branch was checked in. Default is \'main\'.')
param webSitesSourceControlsRepositoryBranch string = 'main'

@description('The folder within the repository that contains the source code of the service. Default is root (\'/\') - but often needs to be set to a sub folder (eg: \'src\').')
param webSitesSourceControlsRepositorySourceLocation string = '/'
// ======================================================================
// VARS
// ======================================================================
var webSitesSourceCountrolsSetupFlag = ( (startsWith(webSitesSourceControlsRepositoryUrl, 'http')) && (length(webSitesSourceControlsRepositoryUrl)>20) )
// ======================================================================
// Resource bicep: ServerFarm
// ======================================================================

module webServerFarmsModule '../microsoft/web/serverfarms.bicep' = if (buildResource) {
  name:  '${deployment().name}_serverFarms_module'
  scope: resourceGroup(resourceGroupName)
  params: {
    resourceName               : toLower('${webServerFarmsResourceName}')
    resourceLocationId         : webServerFarmsResourceLocationId
    resourceTags               : union(defaultResourceTags, sharedSettings.defaultTags, webServerFarmsResourceTags)

    resourceSKU                : webServerFarmsResourceSKU
  }
}
// ======================================================================
// Resource bicep: Sites
// ======================================================================
module webSitesModule '../microsoft/web/sites.bicep' = if (buildResource) {
  // depends implicitely on the
  // [webServerFarmsModule]
  // pass parameters:
  name:  '${deployment().name}-sites-module'
  scope: resourceGroup(resourceGroupName)
  params: {
    // Implicit dependence:
    parentResourceId           : webServerFarmsModule.outputs.resourceId
    //
    resourceName               : toLower('${webSitesResourceName}${defaultResourceNameSuffix}')
    resourceLocationId         : webSitesResourceLocationId
    resourceTags               : union(defaultResourceTags, sharedSettings.defaultTags, webSitesResourceTags)
    //
    httpsOnly                  : webSitesHttpOnly
    identityType               : webSitesIdentityType
    linuxFxVersion             : webSitesLinuxFxVersion
  }
}
// ======================================================================
// Resource bicep: Sites/SourceControls
// ======================================================================
module webSitesSourceControlsModule '../microsoft/web/sites/sourcecontrols.bicep' = if (buildResource && webSitesSourceCountrolsSetupFlag && false) {
  dependsOn: [webSitesModule]
  name:  '${deployment().name}-sites-sc-module'
  scope: resourceGroup(resourceGroupName)
  // child resources don't use 'scope', they use 'parent':
  // parent: webSitesModule
  params: {
    resourceName               : toLower('${webSitesSourceControlsResourceName}${defaultResourceNameSuffix}') //  sitesModule.outputs.resourceName      // Note: Same name as parent site:
    resourceLocationId         : webSitesSourceControlsResourceLocationId
    resourceTags               : union(defaultResourceTags, sharedSettings.defaultTags, webSitesSourceControlsResourceTags)
    //
    repositoryUrl              : webSitesSourceControlsRepositoryUrl
    repositoryToken            : webSitesSourceControlsRepositoryToken
    repositoryBranch           : webSitesSourceControlsRepositoryBranch
    repositorySourceLocation   : webSitesSourceControlsRepositorySourceLocation
  }
}

// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================
// IMPORTANT: The following ids are needed to assign rights
output webServerFarmsResourceName string = webServerFarmsModule.outputs.resourceName
output webServerFarmsResourceId string = webServerFarmsModule.outputs.resourceId

output webSitesResourceName string = webSitesModule.outputs.resourceName
output webSitesResourceId string = webSitesModule.outputs.resourceId

output webSitesDefaultHostName string = webSitesModule.outputs.defaultHostName
output webSitesCustomDomains array = webSitesModule.outputs.customDomains



output webSitesResourcePrincipalId string = webSitesModule.outputs.resourcePrincipalId

// IMPORTANT: Output Managed Identity info
output resourcePrincipalId string = webSitesModule.outputs.resourcePrincipalId

// And the normal ones:
output resource object = webSitesModule.outputs.resource
output resourceId string = webSitesModule.outputs.resourceId
output resourceName string = webSitesModule.outputs.resourceName
// param sink (to not cause error if param is not used):
output _ bool = startsWith('${sharedSettings.version}=${defaultResourceLocationId}-${buildResourceGroup}', '.')
