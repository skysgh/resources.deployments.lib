// ======================================================================
// References:
// ======================================================================
// https://learn.microsoft.com/en-us/azure/search/search-get-started-bicep?tabs=CLI

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
@description('Service name must only contain lowercase letters, digits or dashes, cannot use dash as the first two or last one characters, cannot contain consecutive dashes, and is limited between 2 and 60 characters in length.')
@minLength(2)
@maxLength(60)
param resourceName string

@description('Location for the resource.')
param resourceLocationId string = resourceGroup().location

@description('The tags to merge for this resource.')
param resourceTags object = {}


// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
@description('The pricing tier of the search service you want to create (for example, \'basic\' or \'standard\'. Default=\'standard\'.).')
param resourceSKU string = 'standard'


// ======================================================================
// Resource other Params
// ======================================================================

@description('Replicas distribute search workloads across the service. At least 2 replicas are needed to support high availability of query workloads (not applicable to the free tier). Default=\'1\'.')
@minValue(1)
@maxValue(12)
param replicaCount int = 1


@description('Partitions allow scaling of document count as well as faster indexing by sharding your index over multiple search units. Default=\'1\'.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

@description('Applicable only for SKUs set to standard3. You can set this property to enable a single, high density partition that allows up to 1000 indexes, which is much higher than the maximum indexes allowed for any other SKU.')
@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
var useName = resourceName
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)


// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Search/searchServices@2020-08-01' = if (buildResource) {
  name: name
  location: location
  sku: {
    name: resourceSKU
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
    hostingMode: hostingMode
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
