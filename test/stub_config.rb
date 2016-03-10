require 'wake/utils/requireable_hash'
require 'wake/config'

def Config.instance
  @instance ||= send(:new, Utils::RequireableHash.new({
    "github" => {
      "username" => "myobie"
    }
  }))
end
