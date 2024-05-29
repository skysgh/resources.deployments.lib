// ======================================================================
// References
// ======================================================================
// https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep
// https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-bicep-quickstart?view=azuresql&tabs=CLI

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../settings/shared.json')

// Scope is parent resourceGroup:
targetScope='resourceGroup'

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================

@description('The name of this database server resource. Must be *world unique*! MinLength=14 (so as to allow for uniqueString), maxLength 63, lowercase, only alphanumeric and \'-\' (not \'_\').')
@minLength(14)
// example: base-srv-bt-{uniquestring}
@maxLength(63)
param resourceName string

@description('The id of the location for this resource.')
// @allowed([])
param resourceLocationId string

@description('The tags to merge for this resource.')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================

// Database Server has no SKU or Tier - pass thru to Db I guess.

// ======================================================================
// Resource other Params
// ======================================================================

@description('TODO')
@allowed(['None', 'SystemAssigned', 'SystemAssigned,UserAssigned', 'UserAssigned'])
param identityType string


@description('Minimum TLS version to use.')
@allowed(['1.2','1.3'])
param minimalTlsVersion string = '1.3'

//userType


@description('The server\'s admin account name. ')
@minLength(3)
@maxLength(128)
@secure()
param adminUserName string

@description('The server\'s admin account password. Must have 3 of 4 of [a-z], [A-Z], [0-9], or [specialchars]')
@minLength(8)
@maxLength(128)
@secure()
param adminPassword string


// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
// Concat the pieces together:
var useName = toLower(resourceName)
var useLocation = resourceLocationId
var useTags = union(resourceTags, sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Sql/servers@2023-05-01-preview' = if (buildResource) {

  name: useName
  location: useLocation
  tags: useTags

//  identity: {
//    type: identityType
//    userAssignedIdentities: {
//      {customized property}: {}
//    }
//  }

  properties: {
    minimalTlsVersion: minimalTlsVersion

    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword


//    administrators: {
//       administratorType: 'ActiveDirectory'
//       azureADOnlyAuthentication: bool
//       login: 'string'
//       principalType: 'string'
//       sid: 'string'
//       tenantId: 'string'
//     }
//     federatedClientId: 'string'
//     isIPv6Enabled: 'string'
//     keyId: 'string'
//     primaryUserAssignedIdentityId: 'string'
//     publicNetworkAccess: 'string'
//     restrictOutboundNetworkAccess: 'string'
//     version: 'string'
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
output _ bool = startsWith('${sharedSettings.version}-${identityType}', '.')
