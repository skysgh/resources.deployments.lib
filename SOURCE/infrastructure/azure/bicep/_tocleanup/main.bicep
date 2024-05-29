// The default scope of a resource to go within a resource group:
targetScope = 'subscription'

param location string = deployment().location;

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name:'my ResourceGRoup'
  location: location 
}

module swaPointer = 
