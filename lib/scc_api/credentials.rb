# encoding: utf-8

require "fileutils"
require "scc_api/logger"

module SccApi

  # TODO FIXME: add Yardoc comments
  class Credentials
    include Logger

    attr_accessor :username, :password

    # TODO FIXME: this is wrong, SCC uses per service credentials
    # in contrast to NCC which uses fixed name
    DEFAULT_CREDENTIALS_FILE = "/etc/zypp/credentials.d/SCCcredentials"

    def initialize(user, password)
      self.username = user
      self.password = password
    end

    def self.read(file = DEFAULT_CREDENTIALS_FILE)
      content = File.read(file)

      user, passwd = parse(content)
      Credentials.new(user, passwd)
    end

    def write(file = DEFAULT_CREDENTIALS_FILE)
      # create the target directory if it is missing
      dirname = File.dirname(file)
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

      log.info("Writing SCC credentials to #{file}")
      File.write(file, serialize)
    end

    private

    def self.parse(input)
      if input.match /^\s*username\s*=\s*(\S+)\s*$/
        user = $1
      end

      if input.match /^\s*password\s*=\s*(\S+)\s*$/
        passwd = $1
      end

      return [ user,  passwd ]
    end

    def serialize
      "username=#{username}\npassword=#{password}\n"
    end

  end
end
