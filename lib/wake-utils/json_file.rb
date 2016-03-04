require "json"
require "wake-utils/requireable_hash"

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
