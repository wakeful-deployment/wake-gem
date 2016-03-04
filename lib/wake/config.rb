require 'singleton'
require 'forwardable'
require 'fileutils'
require 'wake/config_formatter'

class Config
  include Singleton
  extend Forwardable

  attr_reader :dir, :path, :json_file

  def initialize
    @dir = File.expand_path(File.join("~", ".wake"))
    @path = File.expand_path(File.join(CONFIG_DIR, "config"))

    unless File.exists?(@path)
      FileUtils.mkdir_p(File.dirname(@path))
      File.open(@path, mode: "w", universal_newline: true) do |f|
        f << "{}"
      end
    end

    @json_file = JSONFile.new(@path)
  end

  delegate [:key?, :[], :[]=, :require, :update, :delete, :reload, :empty?, :to_hash] => :json_file

  def get_or_ask_for(key)
    json_file[key] || ask_for(key)
  end

  def ask_for(key)
    $stderr.print "#{key} is required. What should it's value be? "
    answer = $stdin.gets.chomp
    update(key, answer)
    require(key)
  end

  def format
    ConfigFormatter.format_hash(to_hash)
  end
end
