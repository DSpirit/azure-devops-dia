subscription = "<YOUR-SUBSCRIPTION-NAME>"
prefix="dsdev-dia"
az extensions add --name azure-devops
az pipelines variable-group create --name DevOps --variables "Subscriptions.Production=$subscription Prefix=dsdev-dia Domain=foobar.com" --description "Settings" | ConvertFrom-Json

