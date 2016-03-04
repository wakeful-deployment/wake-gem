require 'uri'
require 'wake-azure/azure/model'

module Azure
  class StorageAccount
    include SubResource

    parent :resource_group

    uri { URI("#{resource_group.uri}/providers/Microsoft.Storage/storageAccounts/#{name}") }
  end
end
