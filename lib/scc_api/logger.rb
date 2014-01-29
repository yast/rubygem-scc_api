# encoding: utf-8

require 'logger'
require 'singleton'

module SccApi
  # empty logger
  class NullLogger < ::Logger
    def initialize(*args)
    end

    def add(*args, &block)
    end
  end

  # Singleton log instance used by SccApi::Logger module
  #
  # @example Set own logger
  #   GlobalLogger.instance.log = Logger.new(STDERR)
  class GlobalLogger
    include Singleton

    attr_accessor :log

    # do not log by default
    def initialize
      @log = NullLogger.new
    end
  end

  # Module provides access to gem specific logging. To set logging see GlobalLogger.
  #
  # @example Add logging to class
  #   class A
  #     include SccApi::Logger
  #
  #     def self.f
  #       log.info "self f"
  #     end
  #
  #     def a
  #       log.debug "a"
  #     end
  #   end
  module Logger
    def log
      GlobalLogger.instance.log
    end

    def self.included(base)
      base.extend self
    end
  end
end
