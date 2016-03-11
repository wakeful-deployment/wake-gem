require 'wake/utils/requireable_hash'
require 'wake/config'

def Config.instance
  @instance ||= send(:new, Utils::RequireableHash.new({
    "github" => {
      "username" => "myobie"
    },
    "azure" => {
      "account" => {
        "tenant_id" => "abc",
        "client_id" => "abc",
        "secret" => "xyz",
        "subscription_id" => "abc"
      }
    }
  }))
end
