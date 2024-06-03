// See:
// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep

// ======================================================================
// Scope
// ======================================================================
// Resources are part of a parent resource group:
targetScope='resourceGroup'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../settings/shared.json')

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================

@description('Required. The name of the resource.Tip: usually there is only one resource, set the same as the project name, with only the name of the Resource Group being different per Environment.')
param resourceName string

// ie, can't be: 'resourceGroup().location'
@description('SWAs are deployed globally, so there really is no option.')
@allowed([ 'centralus', 'eastus2', 'eastasia', 'westeurope', 'westus2' ])
param resourceLocationId string = 'eastasia'

@description('The tags for this resource. ')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
@description('The SKU to use.')
@allowed([ 'Free', 'Standard' ])
param resourceSKU string = 'Free'

// ======================================================================
// Resource other Params
// ======================================================================
@description('The path to the app source code relative to the root of the repository. Probably sonmething like \'SRC/\' or similar.')
param appLocation string = '/'

@description('The path to the api source code relative to the root of the repository.')
param apiLocation string = ''

@description('The output path of the app after building the app source code found in \'appLocation\'. For an angular app that might be something like \'dist/xxx\' ')
param outputLocation string = './dist/xxx'


@description('A custom command to run during deployment of the static content application.e.g. \'npm run build\'')
param appBuildCommand string = 'npm install && npm run build'

@description('A custom command to run during deployment of the Azure Functions API application.')
param apiBuildCommand string = ''


// @description('Whether or not the newly generated repository is a private repository. Defaults to false (i.e. public).')
// param isPrivate string = false

@description('URL for the repository of the static site.')
param repositoryUrl string = ''

@description('The target branch in the repository.')
param repositoryBranch string = 'main'

@description('A user\'s github repository token. This is used to setup the Github Actions workflow file and API secrets.')
@secure() // can't provide a default value if marked secure.
param repositoryToken string

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = resourceName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// Make a dummy var to create a fake need, so that I don't have to comment out the params


// SECRET param sink (to not cause error if param is not used):
var __ = startsWith('${repositoryToken}', '.')


// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Web/staticSites@2022-09-01' = if (buildResource) {
  name: useName
  location: useLocation
  tags: useTags

  sku: {
    // capabilities: [
    //  {
    //    name: resourceSKU
    //    // reason: 'string'
    //    value: resourceSKU
    //  }
    // ]
    // capacity: int
    // family: 'string'
    //locations: [
    //  'string'
    //]
     name: resourceSKU
    // size: 'string'
    // skuCapacity: {
    //  default: int
    //  elasticMaximum: int
    //  maximum: int
    //  minimum: int
    //  scaleType: 'string'
    //}
    tier: resourceSKU
  }
  // kind: 'string'
 // identity: {
  //  type: 'string'
  //  userAssignedIdentities: {}
  //}
  properties: {
    // allowConfigFileUpdates: bool
    // Source Code Repository:
     // provider: 'GitHub'
     repositoryUrl: repositoryUrl
     repositoryToken: repositoryToken
     branch: repositoryBranch

    // Build Properties
    buildProperties: {
      // The path to the app code sections within the repository.
      apiLocation: apiLocation
      appLocation: appLocation

      // the code compilation commands:
      apiBuildCommand: apiBuildCommand
      appBuildCommand: appBuildCommand

      // Location of compiled code:
      outputLocation: outputLocation

      // githubActionSecretNameOverride: 'string'
      // skipGithubActionWorkflowGeneration: bool
    }
    // enterpriseGradeCdnStatus: 'string'

    // stagingEnvironmentPolicy: 'string'
    // templateProperties: {
    //  description: 'string'
    //  isPrivate: bool
    //  owner: 'string'
    //  repositoryName: 'string'
    //  templateRepositoryUrl: 'string'
    // }

    // access 
    publicNetworkAccess: 'Enabled'
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
output _ bool = startsWith(concat('${sharedSettings.version}-${repositoryUrl}-${repositoryBranch}--${__}'), '.')

// Url to website where it is deployed:
// can be accessed from a parent module invoking this module using:
//output swaUrl string = swaModule.outputs.resourceUrl
output resourceUrl string = resource.properties.defaultHostname


