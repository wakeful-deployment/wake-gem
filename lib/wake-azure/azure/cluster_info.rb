module Azure
  class ClusterInfo
    def initialize(specification)
      @specification = specification
    end

    def azure
      @specification.require("azure")
    end

    def location
      azure.require("location")
    end

    def default_size
      azure.require("default_size")
    end

    def agent_host_image_uri
      if azure["agent_host_image_uri"]
        URI(azure["agent_host_image_uri"])
      end
    end

    def server_host_image_uri
      if azure["server_host_image_uri"]
        URI(azure["server_host_image_uri"])
      end
    end

    def seed_host_image_uri
      if azure["seed_host_image_uri"]
        URI(azure["seed_host_image_uri"])
      end
    end

    def self.get(m, &blk)
      ivar_name = :"@#{m}"
      string_name = m.to_s

      define_method(:"#{m}?") do
        !!azure[string_name]
      end

      define_method(m) do
        instance_variable_get(ivar_name) || instance_exec(&blk).tap do |result|
          instance_variable_set(ivar_name, result)
        end
      end
    end

    get :resource_group do
      ResourceGroup.new(subscription: Azure.subscription,
                        name: azure.require("resource_group"),
                        location: location)
    end

    get :storage_account do
      StorageAccount.new(resource_group: resource_group,
                         name: azure.require("storage_account"))
    end

    get :vnet do
      Vnet.new(resource_group: resource_group,
               name: azure.require("vnet"))
    end

    get :subnet do
      Subnet.new(vnet: vnet, name: azure.require("subnet"))
    end
  end
end
