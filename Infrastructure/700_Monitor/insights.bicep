param p_appInsights_name string = 'insights'
param p_logAnalytics_name string = 'logs'
param p_prefix string
param p_location string
param p_environment string

var v_appInsights_name = '${p_prefix}-${p_appInsights_name}-${p_location}-${p_environment}'
var v_logAnalytics_workspace_resourceGroup_name = '${p_prefix}-global-x'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: p_logAnalytics_name
  scope: resourceGroup(v_logAnalytics_workspace_resourceGroup_name)
}

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: v_appInsights_name
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
