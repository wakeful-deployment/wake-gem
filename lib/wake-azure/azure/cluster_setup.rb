module Azure
  class ClusterSetup
    attr_reader :specification

    def initialize(specification)
      @specification = specification
    end

    def resource_group
      @resource_group ||= ResourceGroup.new(subscription: Azure.subscription,
                                            name:         specification.name,
                                            location:     specification.datacenter)
    end

    def create_resource_group
      Azure.resources.resource_groups.exists?(resource_group) ||
        Azure.resources.resource_groups.put!(resource_group)

      specification.update("azure.resource_group", resource_group.name)
    end

    def storage_account_name
      @storage_account_name ||= resource_group.name.gsub(/-/, '')
    end

    def storage_account
      @storage_account ||= StorageAccount.new(resource_group: resource_group,
                                              name:           storage_account_name)
    end

    def create_storage_account
      Azure.resources.storage_accounts.exists?(storage_account) ||
        Azure.resources.storage_accounts.put!(storage_account)

      ProvisioningStatePoller.call(resource: Azure.resources.storage_accounts, model: storage_account)

      specification.update("azure.storage_account", storage_account.name)
    end

    def vnet_name
      @vnet_name ||= "#{resource_group.name}-vnet"
    end

    def vnet
      @vnet ||= Vnet.new(resource_group: resource_group, name: vnet_name)
    end

    def create_vnet
      Azure.resources.vnets.exists?(vnet) ||
        Azure.resources.vnets.put!(vnet)

      specification.update("azure.vnet", vnet.name)
    end

    def subnet_name
      @subnet_name ||= "#{specification.name}-subnet"
    end

    def subnet
      @subnet ||= Subnet.new(vnet: vnet, name: subnet_name)
    end

    def create_subnet
      Azure.resources.subnets.exists?(subnet) ||
        Azure.resources.subnets.put!(subnet)

      specification.update("azure.subnet", subnet.name)
    end

    def dns_zone
      @dns_zone ||= DNSZone.new(resource_group: resource_group, name: specification.dns_zone)
    end

    def create_dns_zone
      Azure.resources.dns_zones.exists?(dns_zone) ||
        Azure.resources.dns_zones.put!(dns_zone)
    end

    def call
      create_resource_group
      create_storage_account
      create_vnet
      create_subnet
      create_dns_zone
    end
  end
end
