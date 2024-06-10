// ======================================================================
// Scope
// ======================================================================
// Scope is parent resourceGroup:
targetScope='resourceGroup'

// ======================================================================
// Import shared settings
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
// Resource that is required to be set up before
// instantiating (and associating to it) a
// server

@description('The name for the resource (serverFarms). IMPORTANT: Note that it may have one or more nested servers under it. ')
param resourceName string

@description('Location of the resource.')
// @allowed([ ''])
param resourceLocationId string

@description('Tags to merge in.')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
@description('The service plan SKU')
@allowed(['F1','D1','B1','B2','S1','S2'])
param resourceSKU string = 'F1'

// ======================================================================
// Resource Other Params
// ======================================================================
@description('The type of OS.')
// @allowed([ ''])
param serverKind string = 'linux'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = resourceName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Web/serverfarms@2022-09-01' = if (buildResource) {
  name: useName
  location: useLocation
  tags: useTags
  sku: {
//    capabilities: [
//      {
//        name: 'string'
//        reason: 'string'
//        value: 'string'
//      }
//    ]
//    capacity: int
//    family: 'string'
//    locations: [
//      'string'
//    ]
    name:resourceSKU
//    size: 'string'
//    skuCapacity: {
//      default: int
//      elasticMaximum: int
//      maximum: int
//      minimum: int
//      scaleType: 'string'
//    }
//    tier: 'string'
  }
  kind: serverKind

//   extendedLocation: {
//    name: 'string'
//  }
  properties: {
//    elasticScaleEnabled: bool
//    freeOfferExpirationTime: 'string'
//    hostingEnvironmentProfile: {
//      id: 'string'
//    }
//    hyperV: bool
//    isSpot: bool
//    isXenon: bool
//    kubeEnvironmentProfile: {
//      id: 'string'
//    }
//    maximumElasticWorkerCount: int
//    perSiteScaling: bool
    reserved: true
//    spotExpirationTime: 'string'
//    targetWorkerCount: int
//    targetWorkerSizeId: int
//    workerTierName: 'string'
//    zoneRedundant: bool
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
