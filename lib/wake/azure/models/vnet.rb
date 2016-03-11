require 'wake/azure/sub_resource'

module Azure
  class Vnet
    include SubResource

    parent   :resource_group
    optional :address_prefix, default: "10.0.0.0/8"
  end
end
