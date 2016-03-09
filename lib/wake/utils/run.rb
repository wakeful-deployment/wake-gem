require 'open3'
require 'wake/utils/log'

$stdout.sync = true
$stderr.sync = true

module Utils
  module Run
    @@buffers = {
      out: "",
      err: "",
      current: :out
    }

    def current?(type)
      @@buffers[:current] == type
    end

    def io(type)
      if type == :out
        $stdout
      else
        $stderr
      end
    end

    def swap(current_type)
      if current_type == :out
        :err
      else
        :out
      end
    end

    def self.print(char, type)
      io(type).tap do |std|
        std.print char
        std.flush
      end
    end

    def self.output(char, std:)
      @@buffers[std] << char # accumulate for later

      if current? std
        print char, std # print, since we are current

        if char == ?\r || char == ?\n
          # if we have a new line or return then clear out current buffer to singal a good time to swap
          @@buffers[std].clear
        end
      elsif @@buffers[swap(std)].empty?
        # if the opposite buffer is empty, and we are not current, let's just become current
        # the opposite buffer will be empty if there has been no output or if we just saw a new line or return
        # (a clean break)
        print @buffers[std], std # output all saved chars
        @@buffers[:current] = std # swap current output for other output
      end
    end

    def flush
      current = @@buffers[:current]
      other   = swap(current)

      print @@buffers[current], current unless @@buffers[current].empty?
      print @@buffers[other],   other   unless @@buffers[other].empty?
    end

    def self.run(cmd, streamer = nil, log: false)
      force_log = log
      Log.log "$ #{cmd}"

      Open3.popen3(cmd) do |i, o, e, t|
        out = ""
        err = ""

        out_thread = Thread.new do
          while stdout = o.read(1)
            if stdout
              if Log.verbose? || force_log
                output stdout, std: :out
              end
              out << stdout
            end
          end
        end

        err_thread = Thread.new do
          while stderr = e.read(1)
            if stderr
              if Log.verbose? || force_log
                output stderr, std: :err
              end
              err << stderr
            end
          end
        end

        out_thread.join
        err_thread.join

        [out, err, t.value]
      end
    end

    def self.run!(cmd, *args, **opts)
      out, err, code = run(cmd, *args, **opts)

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

      [out,err]
    end
  end
end
