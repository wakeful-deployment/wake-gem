require 'wake-azure/run'
require 'wake-azure/powershell'

module Azure
  class SCP
    attr_reader :ip, :local_path, :destination, :username

    def github_username
      WakeConfig.get_or_ask_for("github.username")
    end

    def initialize(ip:, local_path:, username: github_username, destination: "/home/#{username}")
      @ip = ip
      @local_path = local_path
      @destination = destination
      @username = username

      if Wake.powershell?
        @local_path.gsub!(/^(.):/) {"/#{$1}" }
      end
    end

    def scp_command
      "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{local_path} #{username}@#{ip}:#{destination}"
    end

    def call
      run! scp_command
    end

    def self.call(**opts)
      new(**opts).call
    end
  end
end
