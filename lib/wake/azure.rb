require 'wake/config'
require 'wake/azure/token_provider'

module Azure
  def self.datacenters
    @datacenters ||= %w(
      westus
      eastus
      southcentralus
      centralus
      northcentralus
      westeurope
      northeurope
      eastasia
      southeastasia
      japaneast
      japanwest
      australiaeast
      australiasoutheast
      chinaeast
      chinanorth
    ).freeze
  end

  def self.tenant_id
    @tenant_id       ||= Config.instance.get_or_ask_for("azure.account.tenant_id")
  end

  def self.client_id
    @client_id       ||= Config.instance.get_or_ask_for("azure.account.client_id")
  end

  def self.secret
    @secret          ||= Config.instance.get_or_ask_for("azure.account.secret")
  end

  def self.subscription_id
    @subscription_id ||= Config.instance.get_or_ask_for("azure.account.subscription_id")
  end

  def self.token_provider
    @token_provider  ||= TokenProvider.new(tenant_id: tenant_id, client_id: client_id, client_secret: secret)
  end

  def self.subscription
    @subscription    ||= Subscription.new(id: subscription_id)
  end
end

Dir["#{File.expand_path("..", __FILE__)}/**/*.rb"].each do |file|
  require file
end
