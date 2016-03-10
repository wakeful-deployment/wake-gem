require "helper"
require "wake/azure/models"

module Wrapper
  include Azure

  describe Azure do
    let(:valid_resource_group) do
      ResourceGroup.new parent: Azure.subscription, name: "foo", location: Azure.datacenters.first
    end

    let(:valid_dns_zone) do
      DNSZone.new parent: valid_resource_group, name: "foo"
    end

    let(:valid_dns_record_set) do
      DNSRecordSet.new parent: valid_dns_zone, name: "foo"
    end

    let(:valid_vnet) do
      Vnet.new parent: valid_resource_group, name: "foo"
    end

    let(:valid_subnet) do
      Subnet.new parent: valid_vnet, name: "foo"
    end

    let(:valid_public_ip) do
      PublicIP.new parent: valid_resource_group, name: "foo"
    end

    let(:valid_nic) do
      NIC.new parent: valid_resource_group, name: "foo", subnet: valid_subnet
    end

    let(:valid_public_nic) do
      NIC.new parent: valid_resource_group, name: "foo", subnet: valid_subnet, public_ip: valid_public_ip
    end

    let(:valid_storage_account) do
      StorageAccount.new parent: valid_resource_group, name: "foo"
    end

    let(:valid_vm) do
      VM.new parent: valid_resource_group, storage_account: valid_storage_account, nic: valid_nic, name: "foo"
    end

    describe Subscription do
      it "works" do
        s = Subscription.new id: 1
        assert s.valid?
      end
    end

    describe DNSRecordSet do
      it "works" do
        assert valid_dns_record_set.valid?
      end

      it "can have multiple records" do
        d = valid_dns_record_set
        d.add_record ip_address: "10.0.0.1"
        d.add_record ip_address: "10.0.0.2"

        assert_equal 2, d.records.count
      end

      it "must have the location global" do
        assert_equal "global", valid_dns_record_set.location
      end
    end

    describe DNSZone do
      it "works" do
        assert valid_dns_zone.valid?
      end

      it "must have the location global" do
        assert_equal "global", valid_dns_zone.location
      end
    end

    describe NIC do
      it "works" do
        assert valid_nic.valid?
      end

      it "works with a public ip as well" do
        assert valid_public_nic.valid?
      end
    end

    describe PublicIP do
      it "works" do
        assert valid_public_ip.valid?
      end
    end

    describe ResourceGroup do
      it "works" do
        assert valid_resource_group.valid?
      end
    end

    describe StorageAccount do
      it "works" do
        assert valid_storage_account.valid?
      end
    end

    describe Subnet do
      it "works" do
        assert valid_subnet.valid?
      end
    end

    describe VM do
      it "works" do
        assert valid_vm.valid?
      end
    end

    describe Vnet do
      it "works" do
        assert valid_vnet.valid?
      end
    end
  end
end
