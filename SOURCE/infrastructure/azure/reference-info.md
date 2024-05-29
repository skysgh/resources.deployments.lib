# Synopsis #
List of regions for resources.
Note that not all resources can be developed in all regions.

## Regions ##
'asia',
'asiapacific',
'australia',
'australiacentral',
'australiacentral2',
'australiasoutheast',
'australiaeast',
'brazil',
'brazilsouth',
'brazilsoutheast',
'brazilus',
'canada',
'canadacentral',
'canadaeast',
'centralindia',
'centralus', 
'centraluseuap',
'centralusstage',
'eastasia',
'eastasiastage',
'eastus', 
'eastus2', 
'eastus2euap',
'eastusstg',
'eastusstage',
'eastus2stage',
'europe',
'france',
'francecentral',
'francesouth',
'germany',
'germanynorth',
'germanywestcentral',
'global',
'india',
'japan',
'japaneast',
'japanwest',
'jioindiacentral',
'jioindiawest',
'korea',
'koreacentral',
'koreasouth',
'northcentralus',
'northcentralusstage',
'northeurope',
'norway',
'norwayeast',
'norwaywest',
'polandcentral',
'qatarcentral',
'singapore',
'southafrica',
'southafricanorth',
'southafricawest',
'soutcentralus',
'southcentralusstage',
'southcentralusstg',
'southeastasia',
'southeastasiastage',
'southindia',
'swedencentral',
'switzerland',
'switzerlandnorth',
'switzerlandwest',
'uae',
'uaecentral',
'uaenorth',
'uk',
'uksouth',
'ukwest',
'unitedstates',
'unitedstateseuap',
'westcentralus',
'westeurope',
'westindia',
'westus',
'westus2', 
'westus3',
'westusstage',
'westus2stage',


## Param Resource Name Lengths
Use `@minLength` and `@maxLength`.

See: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules


## Param Types
Types include:

* `string`
* `int`
* `bool` (not `boolean`)
* `object`

See: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters

## Tag Param ##
For tags, use `object` as follows:

```
param tagValues object = {
  Dept: 'Finance'
  Environment: 'Production'
}

```

How to merge Objects:

```
var newTags: union(
    commonTags,
  	{
    storageTag1: 'storageTag1'
    storageTag2: 'storageTag2'
  })
```
