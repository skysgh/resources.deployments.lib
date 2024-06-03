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
// Params: Resource SWA  
// ======================================================================
@description('The name of the swa Resource. Required to be universally unique (\'defaultResourceNameSuffix\' will be appended later)')
param swaResourceName string = toLower(defaultResourceName) 

@description('The lowercase identifier of where to build the resource Group if resourceLocation2 is not available. Default is \'global\'.')
@allowed([ 'centralus', 'eastus2', 'eastasia', 'westeurope', 'westus2' ])
param swaResourceLocationId string = toLower(defaultResourceLocationId)

@description('Options are \'Free\' and \'Standard\'. Default is \'Free\'.')
@allowed([ 'Free', 'Standard' ])
param swaResourceSKU string = 'Free'

@description('The tags for this resource. ')
param swaResourceTags object = defaultResourceTags
// ----------------------------------------------------------------------
@description('The domain name (or prefix) to give to the deployed SWA.')
param swaCustomDomain string = ''
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
// Params: Cache   
// ======================================================================
// TODO Front end could/should? be hooked up to Cache later 
// following caching pattern if "closest to user, in user ready format".
// ======================================================================
// ----------------------------------------------------------------------
// Deploys 
// - a Resource Group,
// - a static web app, within it
// Does not:
// - move source code into it.
// ------------------------------------------------------------
// Make the Repo first (I tried foa a while to make it into 
// a module, but could not get the name of the resource that was created
// resource rg1 'Microsoft.Resources/resourceGroups@2022-09-01' = {
//     name: resourceGroupName 
//     // NOT ALLOWED on resource: scope: 'subscription'
//     location: resourceGroupLocationId
//     //params: {
//       tags: useTags
//     //}
// }

//  module resourceGroupsModule '../microsoft/resources/resourcegroups.bicep' = {
//   scope: subscription()
//   name:  '${deployment().name}_resourcegroups_module'
//   // Don't knnow if this needed at this level?
//   params: {
//     resourceGroupName: resourceGroupName
//     resourceGroupLocationId: resourceGroupLocationId
//     resourceGroupTags: union(defaultResourceTags, sharedSettings.defaultTags, resourceGroupTags)
//   }
// }


var useDomainName =  (empty() https://icy-grass-00e2d1e00.5.azurestaticapps.net/

module swaModule '../microsoft/web/staticsites.bicep' = if (buildResource) {
  //dependsOn: [rg1] // Specify a dependency on the rgModule
  name:  '${deployment().name}_swa_module'
  scope: resourceGroup(resourceGroupName) 
  // scope: rgResourceId
  // scope: resourceGroup(subscription().id, rgModule.outputs.resourceId)
  // alt way: scope: resourceGroup(rgModule.outputs.resourceName) // Specify the resource group as the scope
  params: {
    // --------------------------------------------------
    resourceName: toLower('${swaResourceName}${defaultResourceNameSuffix}')
    resourceLocationId: swaResourceLocationId
    resourceTags: union(defaultResourceTags, sharedSettings.defaultTags,swaResourceTags)
    // --------------------------------------------------
    //Resource Capacity:
    resourceSKU: swaResourceSKU
    // --------------------------------------------------
    // Source Code Repository:
    repositoryUrl: swaRepositoryUrl
    repositoryBranch: swaRepositoryBranch
    repositoryToken: swaRepositoryToken
    // --------------------------------------------------
    // Source Code (Front end):
    appLocation: swaAppLocation
    appBuildCommand: swaAppBuildCommand
    // --------------------------------------------------
    // Transpiled result for Runtime:
    outputLocation: swaOutputLocation
    // Source Code (back end):
    apiLocation: swaApiLocation
    // --------------------------------------------------
  }
}



module swaCustomDomainModule '../microsoft/web/staticsites.customdomains.bicep' = if (buildResource && !empty(swaCustomDomain)) {
  //dependsOn: [rg1] // Specify a dependency on the rgModule
  name:  '${deployment().name}_swa_cd_module'
  scope: resourceGroup(resourceGroupName) 
  // scope: rgResourceId
  // scope: resourceGroup(subscription().id, rgModule.outputs.resourceId)
  // alt way: scope: resourceGroup(rgModule.outputs.resourceName) // Specify the resource group as the scope
  params: {
    parentResourceName: toLower('${swaResourceName}${defaultResourceNameSuffix}')
     resourceName:swaCustomDomain 
     kind:'cname'
  }
}

output swaResourceId string = swaModule.outputs.resourceId

output swaResourceName string = swaModule.outputs.resourceName

// Get the Url of the created SWA:
// the invoking yaml file can get its hand on this using:
output swaUrl string = swaModule.outputs.resourceUrl

// Create a fake use for the dummary var:
output repositorySummary string = '${swaRepositoryUrl}-${swaRepositoryBranch}'

// param sink (to not cause error if param is not used):
// removed: ${swaRepositoryToken}
output _ bool = startsWith('${sharedSettings.version}-${resourceGroupName}-${buildResourceGroup}', '.')
