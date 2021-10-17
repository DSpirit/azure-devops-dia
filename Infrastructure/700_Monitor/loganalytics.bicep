param p_logAnalytics_name string = 'logs'
param p_logAnalytics_sku string = 'Standard'
param p_prefix string

// Variables
var v_logAnalytics_name = '${p_prefix}-${p_logAnalytics_name}'

// Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: v_logAnalytics_name
  location: resourceGroup().location
  properties: {
    sku: {
      name: p_logAnalytics_sku
    }
  }
}
