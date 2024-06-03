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
// Parent REsource Name
// ======================================================================
param parentResourceName string

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================

@description('Required. The custom domain of the resource.')
param resourceName string 

@description('Not required. Default is: \'StaticSite\'.')
param kind string = 'StaticSite'


// ======================================================================
// Resource Specific Paramters
// ======================================================================
@description('')
@allowed(['cname','type',])
param validationMethod string = 'cname'



// ======================================================================
// IF DOING A STATIC DOMAIN
// ======================================================================
resource resource 'Microsoft.Web/staticSites/customDomains@2022-09-01' = if (buildResource) {
  name: toLower('${parentResourceName}/${resourceName}')
  kind: kind
  properties: {
    validationMethod: validationMethod
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
