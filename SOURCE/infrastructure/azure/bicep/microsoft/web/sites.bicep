// ======================================================================
// References:
// ======================================================================
// https://learn.microsoft.com/en-us/azure/app-service/quickstart-arm-template?pivots=platform-linux
// https://learn.microsoft.com/en-us/azure/app-service/provision-resource-bicep

// ======================================================================
// Scope
// ======================================================================
// Scope is parent resourceGroup:
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

@description('Id of parent app Service Plan. eg: \'appServicePlanModule.id\'')
param parentResourceId string

@description('the unique name of this site (often is PROJECTNAME + a unique number).')
param resourceName string

@description('The id of the resource for the site.')
// @allowed('')
param resourceLocationId string

@description('The tags to merge for this resource.')
param resourceTags object = {}
// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================


// ======================================================================
// Resource other Params
// ======================================================================
@description('Whether to only allow https. Should be true.')
param httpsOnly bool = true

@description('The Function eXtension to define the runtime stack. Default = \'DOTNETCORE|Latest\'. See https://github.com/MicrosoftDocs/azure-docs/issues/47749')
// Consider also: 'Node|20'
@allowed(['DOTNETCORE:8.0','DOTNETCORE|Latest'])
param linuxFxVersion string = 'DOTNETCORE|Latest'

@description('The type of identity. Default is \'SystemAssigned\' which means creation of *slot specific* Entra Managed Id, that is picked up by outputs at bottom.')
@allowed(['None', 'SystemAssigned', 'SystemAssigned, UserAssigned', 'UserAssigned'])
param identityType string  = 'SystemAssigned'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = resourceName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Web/sites@2020-06-01' = if (buildResource) {
  name: useName
  location: useLocation
  tags: useTags

  identity: {
    type: identityType
  }
  properties: {
    serverFarmId: parentResourceId
    httpsOnly: httpsOnly
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      // Not essential, just showing how to set config values here.
      appSettings: [
        {
          name: 'server'
          value: parentResourceId
        }
        {
          name: 'site'
          value: resourceName
        }
      ]
    }
  }
}

// ======================================================================
// Default Outputs: resource, resourceId, resourceName & variable sink
// ======================================================================

// IMPORTANT: Output Managed Identity info
output resourcePrincipalId string = resource.identity.principalId

// Provide ref to developed resource:
output resource object = resource
// return the id (the fully qualitified name) of the newly created resource:
output resourceId string = resource.id
// return the (short) name of the newly created resource:
output resourceName string = resource.name

output defaultHostName string = resource.properties.defaultHostName
output customDomains array = resource.properties.hostNames



// param sink (to not cause error if param is not used):
output _ bool = startsWith(concat('${sharedSettings.version}'), '.')
