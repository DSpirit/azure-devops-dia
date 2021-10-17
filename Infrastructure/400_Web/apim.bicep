param p_apiManagement_serviceName string
param p_apiManagement_sku string
param p_apiManagement_capacity int
param p_virtualNetworks_resourceGroup_name string
param p_virtalNetworks_name string
param p_virtualNetworks_subnet_name string
param p_keyVaults_resourceId string
param p_domainSuffix string
param p_publisherEmail string
param p_prefix string
param p_location string
param p_environment string
param p_deployCertificate bool = false

var v_apiManagement_name = '${p_prefix}-${p_apiManagement_serviceName}-${p_location}-${p_environment}'
var v_apiManagement_host = p_environment == 'prod' ? 'apis.${p_domainSuffix}' : '${p_environment}-apis.${p_domainSuffix}'
var v_apiManagement_portal = p_environment == 'prod' ? 'apis-portal.${p_domainSuffix}' : '${p_environment}-apis-portal.${p_domainSuffix}'
var v_apiManagement_scm = p_environment == 'prod' ? 'apis-scm.${p_domainSuffix}' : '${p_environment}-apis-scm.${p_domainSuffix}'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${p_virtalNetworks_name}/${p_virtualNetworks_subnet_name}'
  scope: resourceGroup(p_virtualNetworks_resourceGroup_name)
}

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: v_apiManagement_name
  location: resourceGroup().location
  tags: {}
  sku: {
    name: p_apiManagement_sku
    capacity: p_apiManagement_capacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: p_publisherEmail
    publisherName: p_publisherEmail
    virtualNetworkConfiguration: {
      subnetResourceId: subnet.id
    }
    virtualNetworkType: 'Internal'
    hostnameConfigurations: p_deployCertificate ? [
      {
        type: 'Proxy'
        hostName: v_apiManagement_host
        keyVaultId: p_keyVaults_resourceId
        negotiateClientCertificate: false
        defaultSslBinding: true
      }
      {
        type: 'Management'
        hostName: v_apiManagement_scm
        keyVaultId: p_keyVaults_resourceId
        negotiateClientCertificate: false
        defaultSslBinding: false
      }
      {
        type: 'DeveloperPortal'
        hostName: v_apiManagement_portal
        keyVaultId: p_keyVaults_resourceId
        negotiateClientCertificate: false
        defaultSslBinding: false
      }
    ] : []
  }
}

resource r_apiManagement_service_identityProvider 'Microsoft.ApiManagement/service/identityProviders@2020-12-01' = {
  name: 'aad'
  parent: apiManagementService
}

output o_apiManagement_managedIdentity_objectId string = apiManagementService.identity.principalId
output o_apiManagement_managedIdentity_tenantId string = apiManagementService.identity.tenantId
