require "helper"
require "wake/azure"

describe Azure do
  it "has some datacenters" do
    refute Azure.datacenters.empty?
  end

  it "has a tenant_id" do
    assert Azure.tenant_id
  end

  it "has a client_id" do
    assert Azure.client_id
  end

  it "has a secret" do
    assert Azure.secret
  end

  it "has a subscription_id" do
    assert Azure.subscription_id
  end

  it "has a token provider" do
    assert Azure.token_provider
  end

  it "has a subscription" do
    assert Azure.subscription
  end
end
