require 'wake/azure/sub_resource'

module Azure
  class PublicIP
    include SubResource

    parent :resource_group
  end
end
