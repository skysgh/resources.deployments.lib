// ======================================================================
// Background
// ======================================================================
// A resonable set of resources that use resources as a service, 
// not trying to solve it in an older lan based way.

// ======================================================================
// Background
// ======================================================================
// It's important to know the following impacts design:
// Naming:
// - impacted by:
//   https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
// - Resource Groups: maxLength:90.Most chars ok.
// - Sql Server: names must be globally unique.
//   whereas Sql Server Database names do not. 
// - Web Server: farm names are not required to be globally unique
//   whereas names of Web Sites on them must be globally unique. 
// - StorageAccounts: must be globally unique, can only be 24 chars long. 
//   which with a uniquestring (13 chars) means only 11 chars prefix ok.
// - most names are max 50, lowercase, alphanumeric, and hyphens. 
//   but limited by storageAccount (no hyphens, max 24),
//   unless blockchainMembers (20) or cloudservice (15).
// = HENCE:
// - Resource Group names are uppercase (PROJNAME-ENV-PROJTIER-SERVICE)
// - Resource names are all made lowercase (PROJNAME), 
//   suffixed with uniqueString(RESOURCEGROUP)
//   limited to no hyphens/no underscores, a max of 11 chars Only
//
// Design:
// - Taking advantage of *managed* resources, 
//   And with no requirement for dedicated machines, scaling, vnets.
//   (Otherwise ,why bother with hosting in the cloud?)
//   It also lowers cost.
//   But it does put the security onus on the code being secure in its
//   own right, rather than relying on hardware (WAF).
//   That means that, for one, checkins must be protected by code branch
//   protection that checks code before merging.
//   It's more work upfront, but less cost over the service lifespan.
//   The decision of course depends on the talent you have available.
// 
// ======================================================================
// Contents
// ======================================================================
// Static Web App (SWA)
//
// ======================================================================
// Properties: Required: Secrets
// ======================================================================
// The Github repo has at least two secrets (Db Admin User Name/pwd)

// ======================================================================
// Properties: Required: Variables
// ======================================================================
// - projectName
// - projectServiceName
// - environmentId
// - defaultResourceLocationId

// ======================================================================
// Properties: Pricing
// ======================================================================
// swaReosourceSKU
// swaResourceFamily?






// ======================================================================
// Scope
// ======================================================================
// by being subscription, permits creation of resource groups in this file
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
// Resources Groups are part of the general subscription
@description('The name used to build resources. e.g.: \'BASE\'. maxLength 11 as limited by StorageAccount names of 24 chars, minus 13 for uniquestring.')
@maxLength(11) // Limited by storageAccount name length (24) minus 13 chars for uniqueString(...)
param projectName string

@description('The id of the environment, to append to the name of resource groups (e.g.: \'BT\').')
@allowed([ 'NP',   'BT','DT','ST','UT','IT','PP','TR','PR'])
param environmentId string

@description('The name used to build the names of resource groups (e.g.: \'SERVICE\', \'CLIENT\', etc.).')
param projectServiceName string

// ======================================================================
// Params: Resource Defaults 
// ======================================================================
@description('The default name of resources.')
param defaultResourceName string = toLower(projectName)

@description('The default location Id of resources.')
//TooManyOptions @allowed(['australiacentral'])
param defaultResourceLocationId string

@description('The tags shared across all resources.')
param defaultResourceTags object = { project: projectName, environment: environmentId, service: projectServiceName }


// ======================================================================
// Params: PRESENTATION Resource Group Specific (Only IF built here)
// ======================================================================
@description('The upper case name of the logic Tier. Default: \'LOGIC\'.')
param clientTierResourceGroupName string = 'CLIENT'

@description('The upper case Name of the Resource Group in whch these resources are built. Recommend it be the default, which is the upperCase of \'projectName-serviceName-envId\'.')
param clientResourceGroupName string = replace( toUpper('${projectName}-${environmentId}-${projectServiceName}-${clientTierResourceGroupName}'),'--','-')

@description('The Location Id of the Resource Group.')
//TooManyOptions @allowed(['australiacentral'])
param clientResourceGroupLocationId string = defaultResourceLocationId

@description('Tags to use if developing the Resource Group.')
param clientResourceGroupTags object = defaultResourceTags

// ======================================================================
// Params: SWA
// ======================================================================
@description('The name of the swa Resource. Required to be universally unique (\'defaultResourceNameSuffix\' will be appended later)')
param swaResourceName string = toLower(defaultResourceName) 

@description('The lowercase identifier of where to build the resource Group if resourceLocation2 is not available. Default is \'global\'.')
@allowed([ 'centralus', 'eastus2', 'eastasia', 'westeurope', 'westus2' ])
param swaResourceLocationId string = toLower(defaultResourceLocationId)

@description('The tags for the resource.')
param swaResourceTags object = defaultResourceTags
// ----------------------------------------------------------------------
@description('Options are \'Free\' and \'Standard\'. Default is \'Free\'.')
@allowed([ 'Free', 'Standard' ])
param swaResourceSKU string = 'Free'
// ----------------------------------------------------------------------
@description('Custom Domain Region. Default: 5')
param swaDomainRegion string = '5' //swaResourceLocationId

@description('Custom Domain.')
param swaCustomDomain string = ''//toLower('${clientResourceGroupName}.${swaDomainRegion}.azurestaticapps.net')
// ----------------------------------------------------------------------
@description('URL for the repository of the static site.')
param swaRepositoryUrl string 

@description('A user\'s github repository token. This is used to setup the Github Actions workflow file and API secrets. e.g.: use secrets.GITHUB_TOKEN')
@secure()
param swaRepositoryToken string

@description('The branch within the repository. Default is \'main\'.')
param swaRepositoryBranch string = 'main'
// ----------------------------------------------------------------------
@description('Location of app source code in repo')
param swaAppLocation string = ''

@description('The path to the api source code relative to the root of the repository.')
param swaApiLocation string = ''
// ----------------------------------------------------------------------
@description('A custom command to run during deployment of the static content application.e.g. \'npm run build\'')
param swaAppBuildCommand string = 'npm run build'

@description('The output path of the app after building the app source code found in \'swaAppLocation\'. For an angular app that might be something like \'dist/xxx/\' ')
param swaOutputLocation string = ''


// ======================================================================
// CLEANUP OF VARS
// ======================================================================


// ======================================================================
// Resource bicep: LOGIC ResourceGroup
// ======================================================================

module logicResourceGroupsModule '../microsoft/resources/resourcegroups.bicep' = if (buildResourceGroup) {
  // pass parameters:
 name:  '${deployment().name}-rg-client'
 scope:subscription()
 params: {
   resourceGroupName: clientResourceGroupName
   resourceGroupLocationId: clientResourceGroupLocationId
   resourceGroupTags: union(clientResourceGroupTags, defaultResourceTags, sharedSettings.defaultTags)
 }
}


// ======================================================================
// Resource bicep: SWA
// ======================================================================

module swaModule './web-static-app-deployment.bicep' = if (buildResource) {
  dependsOn: [logicResourceGroupsModule]
  name:  '${deployment().name}-swa-recipe'
  scope:subscription()
  params: {
    // -----
    resourceGroupName                               : clientResourceGroupName
    // -----
    defaultResourceName                             : projectName
    defaultResourceLocationId                       : defaultResourceLocationId
    defaultResourceTags                             : defaultResourceTags
    // -----
    swaResourceName                                 : swaResourceName
    swaResourceLocationId                           : swaResourceLocationId
    swaResourceTags                                 : swaResourceTags 
    // -----
    swaCustomDomain                                 : swaCustomDomain 
    // -----
    swaResourceSKU                                  : swaResourceSKU 
    // -----
    swaRepositoryUrl                                : swaRepositoryUrl
    swaRepositoryToken                              : swaRepositoryToken
    swaRepositoryBranch                             : swaRepositoryBranch
    // -----
    swaAppLocation                                  : swaAppLocation
    swaApiLocation                                  : swaApiLocation
    // -----
    swaAppBuildCommand                              : swaAppBuildCommand
    swaOutputLocation                               : swaOutputLocation
  }
}

// ======================================================================
// Resource bicep: CACHE
// ======================================================================
// Maybe cache in the future.


// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================

// Main one:
output resourceId string = swaModule.outputs.swaResourceId
output resourceName string = swaModule.outputs.swaResourceName
// In case this file creates more things later (eg cache, etc.)
output swaResourceId string = swaModule.outputs.swaResourceId
output swaResourceName string = swaModule.outputs.swaResourceName

output _ bool = startsWith('${sharedSettings.version}-${swaDomainRegion}...', '.')
