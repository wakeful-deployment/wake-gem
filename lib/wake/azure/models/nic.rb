require 'uri'
require 'wake/azure/model'

module Azure
  class NIC
    include SubResource

    parent   :resource_group
    required :subnet
    optional :public_ip

    uri { URI("#{resource_group.uri}/providers/Microsoft.Network/networkInterfaces/#{name}") }
  end
end
