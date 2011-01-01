class Dir
  module TmpdirBlock
    TmpdirBlock::VERSION = '1.0.0'
    def TmpdirBlock.version() TmpdirBlock::VERSION end

    require 'tmpdir'
    require 'socket'
    require 'fileutils'

    unless defined?(Super)
      Super = Dir.send(:method, :tmpdir)
      class << Dir
        remove_method :tmpdir
      end
    end

    class Error < ::StandardError; end

    Hostname = Socket.gethostname rescue 'localhost'
    Pid = Process.pid
    Ppid = Process.ppid

    def tmpdir(*args, &block)
      options = Hash === args.last ? args.pop : {}

      dirname = Super.call(*args)

      return dirname unless block

      turd = options['turd'] || options[:turd]

      basename = [
        Hostname,
        Ppid,
        Pid,
        Thread.current.object_id.abs,
        rand
      ].join('-')

      42.times do |n|
        pathname = File.join(dirname, "#{ basename }-n=#{ n }")

        begin
          FileUtils.mkdir_p(pathname)
        rescue Object => e
          sleep(rand)
          next
        end

        begin
          return Dir.chdir(pathname, &block)
        ensure
          FileUtils.rm_rf(pathname) unless turd
        end
      end

      raise Error, "failed to make tmpdir in #{ dirname.inspect }"
    end
  end

  Dir.send(:extend, TmpdirBlock)
end

