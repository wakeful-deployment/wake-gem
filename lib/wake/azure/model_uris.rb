require 'wake/azure/model_uri'
require 'wake/azure/models'

module Azure
  ModelURI.instance_exec do
    make DNSRecordSet do
      URI("#{ModelURI(dns_zone)}/#{model.type}/#{model.name}")
    end

    make DNSZone do
      URI("#{ModelURI(model.resource_group)}/providers/Microsoft.Network/dnszones/#{model.name}")
    end

    make NIC do
      URI("#{ModelURI(model.resource_group)}/providers/Microsoft.Network/networkInterfaces/#{model.name}")
    end

    make PublicIP do
      URI("#{ModelURI(model.resource_group)}/providers/Microsoft.Network/publicIPAddresses/#{model.name}")
    end

    make ResourceGroup do
      URI("#{ModelURI(subscription)}/resourceGroups/#{model.name}")
    end

    make StorageAccount do
      URI("#{ModelURI(resource_group)}/providers/Microsoft.Storage/storageAccounts/#{model.name}")
    end

    make Subnet do
      URI("#{ModelURI(model.vnet)}/subnets/#{model.name}")
    end

    make Subscription do
      URI("/subscriptions/#{model.id}")
    end

    make VM do
      URI("#{ModelURI(model.resource_group)}/providers/Microsoft.Compute/virtualMachines/#{model.name}")
    end

    make Vnet do
      URI("#{ModelURI(model.resource_group).uri}/providers/Microsoft.Network/virtualnetworks/#{model.name}")
    end
  end
end
