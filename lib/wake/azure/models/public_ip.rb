require 'wake/azure/sub_resource'

module Azure
  class PublicIP
    include SubResource

    parent :resource_group

    # uri { URI("#{resource_group.uri}/providers/Microsoft.Network/publicIPAddresses/#{name}") }
  end
end
