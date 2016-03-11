require 'wake/azure/model'

module Azure
  class DNSZone
    include Model

    parent   :resource_group
    required :name

    def location
      "global"
    end
  end
end
