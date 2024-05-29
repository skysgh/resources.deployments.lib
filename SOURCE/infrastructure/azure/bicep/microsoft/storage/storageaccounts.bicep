// ======================================================================
// References:
// ======================================================================
// https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types
// https://www.jorgebernhardt.com/bicep-azure-storage-account-cli/
// ======================================================================
// Scope
// ======================================================================

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

@description('Resource *unique* name.Unique:yes, MinLength:3, MaxLength:24, Lowercase alphanumeric (no dashes or underlines)') 
@minLength(3)
@maxLength(24)
param resourceName string

@description('Deployment Location')
// Too long: @allowed(['westeurope''northeurope'])
param resourceLocationId string

@description('Resource Tags. Note: will be merged with the imported sharedTags.defaultTags.')
param resourceTags object = {}

// ======================================================================
// Default SKU, Kind, Tier where applicable
// ======================================================================
// See: https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types
@description('Resource SKU. Default is \'Standard_LRS\' (Standard Locally Redundant Storage). Other options are GLobally redundant (Standard_GRS), Zone Redundant(Standard_ZRS), etc..')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param resourceSKU string = 'Standard_LRS'

@description('Resource Kind. Default is: \'StorageV2\'')
@allowed(['BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', 'StorageV2'])
param resourceKind string = 'StorageV2'



@description('Resource Tier. Required for storage accounts where kind = BlobStorage. Default is: \'Hot\'. Mist be Premium if storage account type=premium block blobs account type')
@allowed(['Cool', 'Hot','Premium'])
param resourceTier string = 'Hot'


@allowed(['None', 'SystemAssigned', 'SystemAssigned,UserAssigned', 'UserAssigned']) 
param identityType string

@description('Whether to only permit https. The answer is always true.'])
@allowed([true]) 
param supportsHttpsTrafficOnly bool = true


@description('Do not open secondary doors - especially for legacy protocols.'). 
@allowed([false]) 
param isSftpEnabled bool = false
// ======================================================================
// Resource other Params
// ======================================================================

@description('Whether ux/clients can access blobs directly, or only through app acting as proxy. Default:\'Disabled\'.')
@allowed(['Disabled','Enabled']) 
param publicNetworkAccess bool = 'Disabled'

// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================
// Develop default variables.
var useName = toLower(resourceName)
var useLocation = resourceLocationId
var useTags = union(resourceTags,sharedSettings.defaultTags)

// ======================================================================
// Resource bicep
// ======================================================================
resource resource 'Microsoft.Storage/storageAccounts@2022-09-01' = if (buildResource) {
  // Must be lower case:
  name: useName
  location: useLocation
  tags: useTags

  sku: {
    name: resourceSKU
  }
  kind: resourceKind

  // extendedLocation: {
  //  name: 'string'
  //  type: 'EdgeZone'
  // }
  // identity: {
  //   type: identityType
  //   userAssignedIdentities: {
  //     {customized property}: {}
  //   }
  // }
  
  properties: {
     accessTier: accessTier

    // allowBlobPublicAccess: bool
    // allowCrossTenantReplication: bool
    // allowedCopyScope: 'string'
    // allowSharedKeyAccess: bool
    // azureFilesIdentityBasedAuthentication: {
    //   activeDirectoryProperties: {
    //     accountType: 'string'
    //     azureStorageSid: 'string'
    //     domainGuid: 'string'
    //     domainName: 'string'
    //     domainSid: 'string'
    //     forestName: 'string'
    //     netBiosDomainName: 'string'
    //     samAccountName: 'string'
    //   }
    //   defaultSharePermission: 'string'
    //   directoryServiceOptions: 'string'
    // }

    // customDomain: {
    //   name: 'string'
    //   useSubDomainName: bool
    // }


// defaultToOAuthAuthentication: bool
    dnsEndpointType: 'string'
    encryption: {
//       identity: {
//         federatedIdentityClientId: 'string'
//         userAssignedIdentity: 'string'
//       }
//       keySource: 'string'
//       keyvaultproperties: {
//         keyname: 'string'
//         keyvaulturi: 'string'
//         keyversion: 'string'
//       }
//       requireInfrastructureEncryption: bool
//       services: {
//         blob: {
//           enabled: bool
//           keyType: 'string'
//         }
//         file: {
//           enabled: bool
//           keyType: 'string'
//         }
//         queue: {
//           enabled: bool
//           keyType: 'string'
//         }
//         table: {
//           enabled: bool
//           keyType: 'string'
//         }
//       }
//     }
//     immutableStorageWithVersioning: {
//       enabled: bool
//       immutabilityPolicy: {
//         allowProtectedAppendWrites: bool
//         immutabilityPeriodSinceCreationInDays: int
//         state: 'string'
//       }
//     }
//     isHnsEnabled: bool
//     isLocalUserEnabled: bool
//     isNfsV3Enabled: bool
//     isSftpEnabled: bool
//     keyPolicy: {
//       keyExpirationPeriodInDays: int
//     }
 //    largeFileSharesState: 'string'
 //    minimumTlsVersion: 'string'
//     networkAcls: {
//       bypass: 'string'
//       defaultAction: 'string'
//       ipRules: [
//         {
//           action: 'Allow'
//           value: 'string'
//         }
//       ]
//       resourceAccessRules: [
//         {
//           resourceId: 'string'
//           tenantId: 'string'
//         }
//       ]
//       virtualNetworkRules: [
//         {
//           action: 'Allow'
//           id: 'string'
//           state: 'string'
//         }
//       ]
//     }
//     publicNetworkAccess: 'string'
//     routingPreference: {
//       publishInternetEndpoints: bool
//       publishMicrosoftEndpoints: bool
//       routingChoice: 'string'
//     }
//     sasPolicy: {
//       expirationAction: 'Log'
//       sasExpirationPeriod: 'string'
//     }
  supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
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

// URL to storage:
output resourceUrl = 'https://${useName}.blob.core.windows.net'
// Url to blob:
// https://*mystorageaccount*.blob.core.windows.net/*mycontainer*/*myblob*
