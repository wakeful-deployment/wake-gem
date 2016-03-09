require 'singleton'
require 'wake/cluster_specification'
require 'wake/config'
require 'wake/utils/json_file'

class ClusterSpecifications
  include Singleton

  NAME_REGEX = /[a-z0-9-]+/.freeze

  def initialize
    @dir = File.expand_path File.join(Config.instance.dir, "clusters")

    unless File.exists? @dir
      FileUtils.mkdir_p @dir
    end
  end

  def file_path(name)
    File.join @dir, "#{name}.json"
  end

  def get(name)
    load file_path(name)
  end

  def load(name = nil, path)
    if File.exists?(path)
      name ||= File.basename(path).split(".").first
      json_file = JSONFile.new path
      ClusterSpecification.new name, json_file
    end
  end

  def create(name:, iaas:, datacenter:, orchestrator:, collaborators: [])
    if name !~ NAME_REGEX
      raise "Only lowercase letters, numbers, and hyphens are allowed for the names of clusters"
    end

    path = file_path name

    if File.exists? path
      raise "Cluster #{name} already exists"
    else
      File.open(path, mode: "w", universal_newline: true) do |f|
        f << "{}"
      end
    end

    cluster = get name

    cluster.update("name", name)
    cluster.update("iaas", iaas)
    cluster.update("datacenter", datacenter)
    cluster.update("orchestrator", orchestrator)
    cluster.update("collaborators", collaborators)

    cluster
  end

  def default
    get Config.instance.get("default_cluster")
  end

  def all
    path = file_path "**/*"
    Dir[path].map do |file|
      load file
    end
  end

  def format
    all.map do |cluster|
      <<~EOF
        #{cluster.name}:
        #{cluster.format}
        
      EOF
    end
  end
end
