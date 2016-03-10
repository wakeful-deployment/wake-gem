require 'securerandom'
require 'wake/config'
require 'wake/azure/sub_resource'

module Azure
  class VM
    include SubResource

    parent   :resource_group
    required :storage_account
    required :nic
    optional :size, default: "Basic_A3"
    optional :host_image_uri
    optional :admin_username, default: ->{ Config.instance.get_or_ask_for("github.username") }
    optional :admin_password, default: ->{ SecureRandom.urlsafe_base64(32) }
    optional :ssh_key_path,   default: ->(m){ "/home/#{m.admin_username}/.ssh/authorized_keys" }
    optional :ssh_public_key
  end
end
