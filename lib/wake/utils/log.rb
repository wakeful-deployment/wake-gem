module Utils
  module Log
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

    module_function

    def log(msg)
      if Log.verbose?
        Log.output msg
      end
    end

    def debug(msg)
      if Log.very_verbose?
        Log.output msg
      end
    end

    def error(msg)
      msg = "** Error: #{msg}"
      Log.output msg, io: $stderr
    end
  end
end
