require 'forwardable'

class Cluster
  extend Forwardable

  attr_reader :name, :json_file

  def initialize(name, json_file)
    @name = name
    @json_file = json_file
  end

  def inspect
    "#<#{self.class.name} {#{name.inspect}}>"
  end

  delegate [:key?, :[], :[]=, :require, :update, :delete, :reload, :empty?, :to_hash] => :json_file

  def iaas
    self["iaas"]
  end

  def datacenter
    self["datacenter"]
  end

  def orchestrator
    self["orchestrator"]
  end

  def dns_zone
    self["dns_zone"]
  end

  def collaborators
    self["collaborators"] || []
  end
end
