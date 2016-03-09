require 'uri'
require 'wake/azure/model'

module Azure
  class Subscription
    include Model

    required :id

    uri { URI("/subscriptions/#{id}") }
  end
end
