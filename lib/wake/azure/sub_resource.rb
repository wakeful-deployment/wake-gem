require "wake/azure/sub_resource"

module Azure
  module SubResource
    def self.included(base)
      base.include Model

      base.instance_exec do
        required :name
        optional :location, default: ->{ parent.location }
      end
    end
  end
end
