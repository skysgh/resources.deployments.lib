// ======================================================================
// References:
// ======================================================================
// https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-bicep-quickstart?view=azuresql&tabs=CLI

// ======================================================================
// Scope
// ======================================================================
// Scope is parent resourceGroup:
targetScope='resourceGroup'

// ======================================================================
// Import Shared Settings
// ======================================================================
var sharedSettings = loadJsonContent('../../../settings/shared.json')

// ======================================================================
// Dependencies
// ======================================================================
 @description('the parent SqlServer *module*\'s symbolic name.')
param parentResourceName string

// ======================================================================
// Control Flags
// ======================================================================
@description('Build the resoure. For testing, can be set to false')
param buildResource bool = true

// ======================================================================
// Default Name, Location, Tags,
// ======================================================================
@description('the name of this database resource. Default is: \'default\'.')
param resourceName string = 'default'

@description('The id of the location for this resource.')
// @allowed([])
param resourceLocationId string

@description('The tags to merge for this resource.')
param resourceTags object = {}

// ======================================================================
// Default SKU, Tier, ...etc.
// ======================================================================
@description('The SKU of this resource.The default is \'Basic\' to save costs.')
// @allowed(['Basic', 'StandardS0', 'StandardS1', 'StandardS2', 'StandardS3', 'StandardS4', 'StandardS6', 'StandardS7', 'StandardS9', 'StandardS12', 'PremiumP1', 'PremiumP2', 'PremiumP4', 'PremiumP6', 'PremiumP11', 'PremiumP15', 'GP_Gen5_2', 'GP_Gen5_4', 'GP_Gen5_8', 'GP_Gen5_16', 'GP_Gen5_24', 'GP_Gen5_32', 'GP_Gen5_40', 'GP_Gen5_80', 'GP_Gen4_2', 'GP_Gen4_4', 'GP_Gen4_8', 'GP_Gen4_16', 'BC_Gen5_2', 'BC_Gen5_4', 'BC_Gen5_8', 'BC_Gen5_16', 'BC_Gen5_24', 'BC_Gen5_32', 'BC_Gen5_40', 'BC_Gen5_80', 'BC_Gen4_2', 'BC_Gen4_4', 'BC_Gen4_8', 'BC_Gen4_16'])
@allowed(['Basic', 'S0', 'S1', 'S2', 'S3', 'S4', 'PremiumP1', 'PremiumP2', 'PremiumP4', 'GP_Gen5_2', 'GP_Gen5_4', 'GP_Gen4_2', 'GP_Gen4_4', 'BC_Gen5_2', 'BC_Gen5_4', 'BC_Gen4_2', 'BC_Gen4_4'])
param resourceSKU string = 'Basic'

@description('The Tier of this resource. The default is \'Basic\' to save costs.')
@allowed(['Basic', 'Standard', 'Premium', 'GeneralPurpose', 'BusinessCritical'])
param resourceTier string = (contains(['Basic', 'S0', 'S1', 'S2', 'S3', 'S4'], resourceSKU) ? 'Standard': (contains(['PremiumP1', 'PremiumP2', 'PremiumP4'], resourceSKU) ?'Premium': (contains(['GP_Gen5_2', 'GP_Gen5_4', 'GP_Gen4_2', 'GP_Gen4_4'], resourceSKU) ? 'GeneralPurpose': (contains(['BC_Gen5_2', 'BC_Gen5_4', 'BC_Gen4_2', 'BC_Gen4_4'], resourceSKU) ? 'BusinessCritical' : 'Basic'))))

// ======================================================================
// Other resource specific vars
// ======================================================================
@description('Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled. Default:2')
param autoPauseDelay int = 60

//@allowed([None', 'UserAssigned'])
//param userType string = 'UserAssigned'

@description('If the DB is free (one per subscription, then what do to when passing free offer. Default: \'BillOverUsage\'. ')
@allowed(['AutoPause', 'BillOverUsage'])
param freeLimitExhaustionBehavior string = 'BillOverUsage'

@description('Specifies the availability zone the database is pinned to.	Default is\'NoPreference\'')
@allowed(['1', '2', '3', 'NoPreference'])
param availabilityZone string = 'NoPreference'

@description('	Collation of the metadata catalog.. Default is \'DATABASE_DEFAULT\' (which is by default \'Latin1_General_CI_AS\').')
@allowed(['DATABASE_DEFAULT', 'SQL_Latin1_General_CP1_CI_AS', 'Latin1_General_CI_AS'])
param catalogCollation string = 'DATABASE_DEFAULT'

@description('	Collation of the metadata catalog. Default is \'Latin1_General_CI_AS\'. (US is \'SQL_Latin1_General_CP1_CI_AS\', NZ-English is \'Latin1_General_CI_AS\', Maori is \'Latin1_General_CI_AI\').')
@allowed(['SQL_Latin1_General_CP1_CI_AS', 'Latin1_General_CI_AS'])
param collation string = 'Latin1_General_CI_AS'

@description('Creation Mode.. Default is \'Default\'.')
@allowed(['Copy', 'Default', 'OnlineSecondary', 'PointInTimeRestore', 'Recovery', 'Restore', 'RestoreExternalBackup', 'RestoreExternalBackupSecondary', 'RestoreLongTermRetentionBackup', 'Secondary'])
param createMode string = 'Default'

@description('Whether the database is a Ledger one, permitting to review historical values. Default is \'true\'.')
param isLedgerOn bool = true

@description('Name of Sample database schema to develop . Default is \'\'.')
@allowed(['', 'AdventureWorksLT', 'WideWorldImportersFull', 'WideWorldImportersStd'])
param sampleName string = ''

@description('Whether or not the database uses free monthly limits. Allowed on one database in a subscription.')
param useFreeLimit bool = false


@description('Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. Default: false')
param zoneRedundant bool = false

@description('Max size of database. Default: 1073741824 bytes (ie 1Gb - which is acceptable for a startup at the beginning but note that it is *small* for relatively production purposes.)')
param maxSizeBytes int = 1073741824



// ======================================================================
// Default Variables: useResourceName, useTags
// ======================================================================


// ======================================================================
// Resourc: Database
// ======================================================================

resource resultResource 'Microsoft.Sql/servers/databases@2023-02-01-preview' = if (buildResource) {


  name: toLower('${parentResourceName}/${resourceName}')
  location: resourceLocationId
  tags: union(sharedSettings.defaultTags, resourceTags)

  sku: {
    //capacity: int
    name: resourceSKU
//    tier: resourceTier
    //family: 'string'
    //size: 'string'
}
//  identity: {
//    type: userType
//    userAssignedIdentities: {
//      The resource ids of the user assigned identities to use
//      {customized property}: {}
//    }
//  }

  properties: {

//useFreeLimit: useFreeLimit 
    freeLimitExhaustionBehavior: freeLimitExhaustionBehavior 

    autoPauseDelay: autoPauseDelay

    zoneRedundant: zoneRedundant  

    availabilityZone: availabilityZone

    createMode: createMode
 
    collation: collation
    catalogCollation: catalogCollation

    isLedgerOn: isLedgerOn     // Develop History tables permitting rollback
    sampleName: sampleName     // If we are building a sample DB
    
    maxSizeBytes: maxSizeBytes 

    // elasticPoolId: 'string'
    // encryptionProtector: 'string'
    // encryptionProtectorAutoRotation: bool
    // federatedClientId: 'string'
    // highAvailabilityReplicaCount: int
    // keys: {
    //   {customized property}: {}
    // }
    // licenseType: 'string'
    // longTermRetentionBackupResourceId: 'string'
    // maintenanceConfigurationId: 'string'
    // manualCutover: bool
    
    // minCapacity: json('decimal-as-string')
    // performCutover: bool
    // preferredEnclaveType: 'string'
    // readScale: 'string'
    // recoverableDatabaseId: 'string'
    // recoveryServicesRecoveryPointId: 'string'
    // requestedBackupStorageRedundancy: 'string'
    // restorableDroppedDatabaseId: 'string'
    // restorePointInTime: 'string'
    // secondaryType: 'string'
    // sourceDatabaseDeletionDate: 'string'
    // sourceDatabaseId: 'string'
    // sourceResourceId: 'string'

  } 
}


// ======================================================================
// Outputs: Custom
// ======================================================================
// output MyConnectionString string = 'Server=tcp:${parentResourceName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${resourceName};Persist Security Info=False;User ID=username;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
// DANGER: Don't want to expose the Admin Name/Pwd in output....but it's worth having it here in case: 
//output connectionStringForDbAdmin string = 'Server=tcp:${reference(resourceName).fullyQualifiedDomainName},1433;Initial Catalog='${resourceName}';Persist Security Info=False;User ID=',reference($parentResourceName).administratorLogin,';Password=',reference($parentResourceName).administratorLoginPassword,';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'

// ======================================================================
// Outputs: Default: resource, resourceId, resourceName & variable sink
// ======================================================================
// Provide ref to developed resource:
output resource object = resultResource
// return the id (the fully qualitified name) of the newly created resource:
output resourceId string = resultResource.id
// return the (short) name of the newly created resource:
output resourceName string = resultResource.name
// param sink (to not cause error if param is not used):
output _ bool = startsWith(concat('${sharedSettings.version}-${resourceTier}-${availabilityZone}-${freeLimitExhaustionBehavior}-${useFreeLimit}-${autoPauseDelay}-${createMode}-${collation}-${catalogCollation}-${isLedgerOn}-${sampleName}-${zoneRedundant}'), '.')

