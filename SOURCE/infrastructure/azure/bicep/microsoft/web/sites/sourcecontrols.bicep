// ======================================================================
// References:
// ======================================================================
// Sub part of Sites (which is a sub part of ServerFarms)
// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites/sourcecontrols?pivots=deployment-language-bicep

// ======================================================================
// Scope
// ======================================================================
// Resources are part of a parent resource group:
targetScope='resourceGroup'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../../settings/shared.json')

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================

@description('the unique name of site.')
param resourceName string

@description('The id of the resource for the site. NOT USED.')
// @allowed('') 
param resourceLocationId string = ''

@description('The tags for this resource. ')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================


// ======================================================================
// Other Resource Params
// ======================================================================
@description('The Url of the repository containing source code of this site.')
param repositoryUrl string

@description('The token to access the repository.')
param repositoryToken string



@description('The Branch of the repository containing source code of this site.')
param repositoryBranch string

@description('The folder within repo containing the source code.')
param repositorySourceLocation string = '/'

@description('.')
param isManualIntegration bool = true


// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================


// Secret sink:
output __ bool = startsWith('${repositoryToken}', '.')

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = if (buildResource) {
  name: '${resourceName}/web'
  // location: resourceLocationId
  // does not exist: tags: useTags

  properties: {
    repoUrl: repositoryUrl
    branch: repositoryBranch

    // Not sure what this is:
    isManualIntegration: isManualIntegration
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
output _ bool = startsWith('${sharedSettings.version}-${resourceLocationId}-${repositorySourceLocation}-${resourceTags}', '.')
