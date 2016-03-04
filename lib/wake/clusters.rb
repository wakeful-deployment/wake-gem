require 'singleton'
require 'wake/cluster'
require 'wake/config'
require 'wake-utils/json_file'

class Clusters
  include Singleton

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
      Cluster.new name, json_file
    end
  end

  def create(name)
    path = file_path name

    unless File.exists? path
      File.open(path, mode: "w", universal_newline: true) do |f|
        f << "{}"
      end
    end

    get name
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
