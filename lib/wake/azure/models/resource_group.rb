require 'wake/azure/model'

module Azure
  class ResourceGroup
    include Model

    parent   :subscription
    required :name
    required :location
  end
end
