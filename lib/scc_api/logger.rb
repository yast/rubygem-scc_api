# encoding: utf-8

require 'logger'
require 'singleton'

module SccApi
  # empty logger
  class NullLogger < Logger
    def initialize(*args)
    end

    def add(*args, &block)
    end
  end

  class Logger
    include Singleton

    attr_accessor :log

    # do not log by default
    def initialize
      @log = NullLogger.new
    end

    def self.log
      Logger.instance.log
    end

    def self.set_logger(logger)
      Logger.instance.log = logger
    end
  end

end
