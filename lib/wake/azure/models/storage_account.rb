require 'wake/azure/sub_resource'

module Azure
  class StorageAccount
    include SubResource

    parent :resource_group
  end
end
