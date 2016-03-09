require 'uri'
require 'wake/azure/model'

module Azure
  class Subnet
    include SubResource

    parent   :vnet
    optional :address_prefix, default: "10.1.0.0/16"

    uri { URI("#{vnet.uri}/subnets/#{name}") }
  end
end
