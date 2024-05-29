// The default scope of a resource to go within a resource group:
targetScope =  'resourceGroup'

// Metadata:
metadata description = 'Creates a Static Web site within a parent Resource Group'

// Expected Parameters:
@description('Provide the system\'s name (eg : \'BASE\') as a prefix for the resource\'s name.')
param systemName string

@description('Provide the resource\'s tier (UX,LOGIC,INFRA).')
@allowed( ['INFRA','SYS','PRES', 'CLIENT'])
param tier string

@description('Specifies the region for the Resource. Defaults to matching Resource Group\'s. But SWAs can\'t be built just anywhere...')
param location string = resourceGroup().location

@description('suffix for names. Default is \'resourceGroup().id\'')
param suffix string = uniqueString(resourceGroup().id)

@description('Resource Resource Group\'s name.')
param name string = '${systemName}-${tier}-${suffix}' 

@description('The SKU for the static web site. Default is \'Free\'')
@allowed( ['Free', 'Standard'])
param sku string = 'Free'


@description('Publicly accessibe URL to (e.g. GitHub) repo containing static web app source code')
param repoUrl string


@description('Source Code Repo Branch.Default is \'main\'')
param repoBranch string='main'

@description('Path to static web site source code within repo, relative to the repo\'s root. Default is \'SOURCE/src\'')
param repoSrcPath string='SOURCE/src'

@description('Name of (eg, Angular) project name (e.g. \'BASE\').')
param repoSystemName string = systemName

@description('Path to static web site source code compilation output, relative to the src\'s root. Default is \'dist/{sitename}')
param buildLocation string='dist/${repoSystemName}'

//@description('Command to use to launch app')
//param appBuildCommand string='npm run'


// Resource definition, based on above provided or default param values:
resource mySWA 'Microsoft.Web/staticSites@2022-09-01' = {
  name: name 
  location: location
  sku:{ 
     capacity:1
     tier: tier
     
  }
    
     properties: {
      // Ensure public can see website:
      publicNetworkAccess: 'enabled'
      // Where to find source code to compile
      repositoryUrl:repoUrl
      branch:repoBranch
      

      buildProperties: {
        // where to find src code in repo (eg: 'SOURCE/myProj')
        appLocation:repoSrcPath
        // Where it will be built to (eg: 'dist/base')
        outputLocation: buildLocation
        
      }
        
     }
}

// Describe outputs for non-secrets:
output swaId string = mySWA.id
