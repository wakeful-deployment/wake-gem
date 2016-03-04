require 'forwardable'
require 'uri'
require 'fileutils'
require 'json'

require_relative './string_utils'

class JSONFile
  def initialize(path)
    @path = path
    @name = File.basename(path)
    reload
  rescue Errno::ENOENT
    fail "#{@path} not found"
  rescue JSON::ParserError
    fail "#{@path} is malformed"
  end

  READ_LOCK = File::LOCK_SH | File::LOCK_NB
  WRITE_LOCK = File::LOCK_EX | File::LOCK_NB
  UNLOCK = File::LOCK_UN

  private def open(type = :read)
    mode, lock = case type
                 when :read
                   ["r", READ_LOCK]
                 when :write
                   ["r+", WRITE_LOCK]
                 end

    File.open(@path, mode: mode, universal_newline: true) do |f|
      counter = 0

      until f.flock(lock) do
        counter += 1

        if counter > 100
          Wake.error "Could not aquire a lock for #{path} after 10 seconds, removing lock..."
          f.flock(UNLOCK)
          f.flock(lock)
          break
        else
          sleep 0.1
        end
      end

      rh = RequireableHash.new(JSON.parse(f.read).to_hash)

      case type
      when :read
        yield(rh)
      when :write
        rh = yield(rh)
        f.rewind
        f.write JSON.pretty_generate(rh)
        f.flush
        f.truncate(f.pos)
        rh
      end
    end
  end

  def to_hash
    @content
  end

  def reload
    open(:read) { |rh| @content = rh } && self
  end

  def key?(key)
    to_hash.key?(key)
  end

  def [](key)
    to_hash[key]
  end

  def []=(key, value)
    to_hash.update(key, value)
  end

  def require(key)
    to_hash.require(key)
  rescue RequireableHash::Error
    fail "#{@path} is missing the required key: #{key}"
  end

  def update(key, value)
    open(:write) do |rh|
      rh.update(key, value)
      @content = rh
    end
  end

  def delete(key)
    open(:write) do |rh|
      rh.delete(key)
      @content = rh
    end
  end

  def empty?
    to_hash.nil? || to_hash.empty?
  end

  def each(&blk)
    to_hash.each(&blk)
  end

  def map(&blk)
    to_hash.map(&blk)
  end
end

require "delegate"

class WrappedArray < SimpleDelegator
  def [](index)
    value = super
    wrap(value)
  end

  def to_ary
    __get_obj__
  end
  alias_method :to_a, :to_ary

  private

  def wrap(value)
    if value.is_a?(Hash)
      RequireableHash.new(value)
    elsif value.is_a?(Array)
      self.class.new(value)
    else
      value
    end
  end
end

class RequireableHash < SimpleDelegator
  class Error < StandardError; end
  class CannotCreate < StandardError; end
  class CannotUpdate < StandardError; end

  class Key
    def initialize(name)
      @name = name
    end

    def get(h)
      if h.is_a?(Hash)
        h[@name]
      end
    end

    def self.default
      {}
    end

    def get_or_create(h, default:)
      if h.is_a?(Hash)
        h[@name] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(h)
      if h.is_a?(Hash)
        h.key?(@name)
      end
    end

    def update(h, value:)
      if h.is_a?(Hash)
        h[@name] = value
      else
        fail CannotUpdate
      end
    end

    def delete(h)
      if h.is_a?(Hash)
        h.delete(@name)
      end
    end
  end

  class Index
    def initialize(number)
      @number = number
    end

    def get(a)
      if a.is_a?(Array)
        a[@number]
      end
    end

    def self.default
      []
    end

    def get_or_create(a, default:)
      if a.is_a?(Array)
        a[@number] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(a)
      if a.is_?(Array)
        !a[@number].nil?
      end
    end

    def update(a, value:)
      if a.is_a?(Array)
        a[@number] = value
      else
        fail CannotUpdate
      end
    end

    def delete(a)
      if a.is_a?(Array)
        a.delete_at(@number)
      end
    end
  end

  class KeysAndIndexes
    attr_reader :ops

    def initialize(ops)
      @ops = ops
    end

    def get(thing)
      ops.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end
    end

    def key?(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.key?(bottom_thing)
      end
    end

    def update(thing, value:)
      ops_to_create_through = ops[0..-2]
      shifted = ops[1..-1]
      list = ops_to_create_through.zip(shifted)

      bottom_thing = list.reduce(thing) do |sub_thing, (op, next_op)|
        op.get_or_create(sub_thing, default: next_op.class.default)
      end

      ops.last.update(bottom_thing, value: value)
    end

    def delete(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.delete(bottom_thing)
      end
    end

    def self.normalize_dots(string)
      string.gsub(/\[(\d+)\]/, '.[\\1].').gsub(/\.{2,}/, '.')
    end

    def self.parse(string)
      normalize_dots(string).split('.').map do |s|
        if s =~ /\A\[(\d+)\]\z/
          Index.new($1.to_i)
        else
          Key.new(s)
        end
      end
    end

    def self.from(string)
      new(parse(string))
    end
  end

  def key?(key)
    KeysAndIndexes.from(key).key?(to_hash)
  end

  def [](key)
    value = KeysAndIndexes.from(key).get(to_hash)
    wrap(value)
  end

  def []=(key, value)
    update(key, value)
  end

  def require(key)
    value = KeysAndIndexes.from(key).get(to_hash)

    fail(Error.new("no key '#{key}'")) if value.nil?

    wrap(value)
  end

  def update(key, value)
    KeysAndIndexes.from(key).update(to_hash, value: value)
  end

  def delete(key)
    KeysAndIndexes.from(key).delete(to_hash)
  end

  def to_hash
    __getobj__
  end
  alias_method :to_h, :to_hash

  private

  def wrap(value)
    if value.is_a?(Hash)
      self.class.new(value)
    elsif value.is_a?(Array)
      WrappedArray.new(value)
    else
      value
    end
  end
end
CONFIG_DIR = File.expand_path(File.join("~", ".wake"))
path = File.expand_path(File.join(CONFIG_DIR, "config"))

unless File.exists?(path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, mode: "w", universal_newline: true) do |f|
    f << "{}"
  end
end

WAKE_CONFIG = JSONFile.new(path)

module WakeConfig
  module_function

  def format(value, keys)
    value.gsub!(/ /, ' ') # non-breaking space so column will do the right thing

    out = "#{keys.join(".")}\t#{value}"

    out.gsub!(/\.\[/, '[') # remove . from before [0] so arrays look better

    out
  end

  def map(array, keys = [])
    array.each_with_index.map do |v, index|
      keys.push("[#{index}]")
      output = if v.is_a?(Hash)
        traverse(v, keys)
      elsif v.is_a?(Array)
        map(v, keys)
      else
        format(v, keys)
      end
      keys.pop
      output
    end
  end

  def traverse(hash, keys = [])
    hash.map do |k, v|
      keys.push(k)
      output = if v.is_a?(Hash)
        traverse(v, keys)
      elsif v.is_a?(Array)
        map(v, keys)
      else
        format(v, keys)
      end
      keys.pop
      output
    end.flatten
  end

  def require(key)
    config.require(key)
  end

  def get(key)
    config[key]
  end

  def get_or_ask_for(key)
    config[key] || ask_for(key)
  end

  def ask_for(key)
    $stderr.print "#{key} is required. What should it's value be? "
    answer = $stdin.gets.chomp
    update(key, answer)
    require(key)
  end

  def update(key, value)
    config.update(key, value)
  end

  def delete(key)
    config.delete(key)
  end

  def all
    traverse(config)
  end

  def config
    WAKE_CONFIG
  end
end

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
    name = WakeConfig.get("default_cluster")

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
