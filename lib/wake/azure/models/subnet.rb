require 'wake/azure/sub_resource'

module Azure
  class Subnet
    include SubResource

    parent   :vnet
    optional :address_prefix, default: "10.1.0.0/16"
  end
end
