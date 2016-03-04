require 'forwardable'
require 'fileutils'
require 'wake/string_utils'
require 'config'

path = File.expand_path(File.join(CONFIG_DIR, "clusters"))

unless File.exists?(path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, mode: "w", universal_newline: true) do |f|
    f << "{}"
  end
end

CLUSTERS = JSONFile.new(path)

class Cluster
  extend Forwardable

  NoDefaultClusterSet = Class.new(StandardError)

  def self.default
    name = Config.get("default_cluster")

    if name
      get(name)
    else
      fail NoDefaultClusterSet
    end
  end

  def self.list
    CLUSTERS.to_hash
  end

  def self.get(name)
    if clusters.key?(name)
      new(name)
    end
  end

  def self.reload
    clusters.reload
  end

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def full_key(key)
    "#{name}.#{key}"
  end

  def inspect
    "#<#{self.class.name} {#{name.inspect}}>"
  end

  def [](key)
    self.class.clusters[full_key(key)]
  end

  def require(key)
    self.class.clusters.require(full_key(key))
  end

  def update(key, value)
    self.class.clusters.update(full_key(key), value)
  end

  def to_hash
    self.class.clusters[name].merge("name" => name)
  end

  def reload
    self.class.reload
    self
  end


  def iaas
    self["iaas"]
  end

  def dns_zone
    self["dns_zone"]
  end

  def collaborators
    self["collaborators"] || []
  end

  def delete
    self.class.clusters.delete(name)
  end
end
