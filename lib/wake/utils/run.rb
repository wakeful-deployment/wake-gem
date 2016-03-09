require 'open3'
require 'monitor'
require 'wake/utils/log'

$stdout.sync = true
$stderr.sync = true

module Utils
  module Run
    module_function

    def run(*args, **opts)
      Command.new(*args, **opts).call
    end

    def run!(cmd, *args, **opts)
      Command.new(*args, **opts).call!
    end
  end

  class CombinedStream
    def initialize(stream1, stream2)
      @stream1, @stream2 = stream1, stream2
    end

    def <<(stuff)
      @stream1 << stuff
      @stream2 << stuff
    end
  end

  class Streamer
    include MonitorMixin

    def initialize(stream)
      @stream = stream
      @buffer = ""
      @current = :none

      super()
    end

    def puts(stuff, type:)
      synchronize do
        if @current == :none
          @current = type
        end

        if @current == type
          @stream << stuff

          last_char = stuff.chars.last

          if last_char == ?\r || last_char == ?\n
            flush_buffer_to_break

            if @buffer.empty?
              @current = :none
            else
              change_and_flush_buffer
            end
          end
        else
          @buffer << stuff
        end
      end
    end

    def change_and_flush_buffer
      if @current == :stdout
        @current = :stderr
      else
        @current = :stdout
      end
      @stream << @buffer
      @buffer.clear
    end

    def flush_buffer_to_break
      index = [@buffer.rindex(?\r), @buffer.rindex(?\n), -1].compact.max

      if index > -1
        part_to_flush = @buffer[0..index]
        @buffer = @buffer[(index+1)..-1]
        @stream << part_to_flush
      end
    end

    def flush
      @stream << @buffer unless @buffer.empty?
      @buffer.clear
      nil
    end
  end

  class Command
    include Log

    attr_reader :cmd

    def initialize(cmd, stream: nil)
      @cmd = cmd

      if stream
        @streamer = Streamer.new(stream)
      end
    end

    def stream(msg, type:)
      @streamer.puts msg, type: type if @streamer
    end

    def flush_stream
      @streamer.flush if @streamer
    end

    def call
      log "$ #{cmd}"

      Open3.popen3(cmd) do |i, o, e, t|
        out = ""
        err = ""

        out_thread = Thread.new do
          while stdout = o.read(1)
            if stdout
              out << stdout
              stream stdout, type: :stdout
            end
          end
        end

        err_thread = Thread.new do
          while stderr = e.read(1)
            if stderr
              err << stderr
              stream stderr, type: :stderr
            end
          end
        end

        out_thread.join
        err_thread.join

        flush_stream

        [out, err, t.value]
      end
    end

    def call!
      out, err, code = call

      unless code.success?
        error_string = ""

        unless out.nil? || out.empty?
          error_string << out
        end

        unless err.nil? || err.empty?
          error_string << err
        end

        fail "`#{cmd}` failed:\n#{error_string}"
      end

      [out, err]
    end
  end
end
