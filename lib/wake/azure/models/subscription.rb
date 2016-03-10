require 'wake/azure/model'

module Azure
  class Subscription
    include Model

    required :id
  end
end
