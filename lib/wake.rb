require 'wake/version'

module Wake
  def self.verbose
    !!@verbose
  end

  def self.very_verbose
    !!@very_verbose
  end

  def self.verbose=(value)
    @verbose = value
  end

  def self.very_verbose=(value)
    @verbose ||= @very_verbose = value
  end

  class << self
    alias_method :verbose?, :verbose
    alias_method :very_verbose?, :very_verbose
  end

  def self.output(msg, io: $stdout)
    if String === msg
      io.puts msg
    else
      io.puts msg.inspect
    end
  end

  def self.log(msg)
    if verbose?
      output msg
    end
  end

  def self.debug(msg)
    if very_verbose?
      output msg
    end
  end

  def self.error(msg)
    msg = "** Error: #{msg}"
    output msg, io: $stderr
  end
end

Dir["#{File.expand_path("..", __FILE__)}/**/*.rb"].each do |file|
  require file
end
