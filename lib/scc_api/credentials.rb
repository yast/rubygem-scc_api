# encoding: utf-8

require "fileutils"
require "scc_api/logger"

module SccApi

  # TODO FIXME: add Yardoc comments
  class Credentials
    include Logger

    # the default location of credential files
    DEFAULT_CREDENTIALS_DIR = "/etc/zypp/credentials.d/"
    # default suffix
    BASEFILE_SUFFIX = "_credentials"

    attr_reader :username, :password, :service

    def initialize(user, password, service)
      @username = user
      @password = password
      @service = service
    end

    def self.read(file)
      content = File.read(file)

      user, passwd = parse(content)
      log.info("Reading credentials from #{file}")
      credentials = Credentials.new(user, passwd, service_name(file))
      log.debug("Read credentials: #{credentials}")
      credentials
    end

    # Write credentials to a file
    def write(dir = nil)
      filename = file_path(dir)

      # create the target directory if it is missing
      dirname = File.dirname(filename)
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

      log.info("Writing credentials to #{filename}")
      log.debug("Credentials to write: #{self}")
      # make sure only the owner can read the content
      File.write(filename, serialize, {:perm => 0600})
    end

    # security - override to_s to avoid writing the password to log
    def to_s
      "#<#{self.class}:#{sprintf("%0#16x", object_id)} @username=#{username.inspect}, @password=\"[FILTERED]\", @service=#{service.inspect}>"
    end

    private

    def self.service_name(file)
      File.basename(file)[/^(.*)#{BASEFILE_SUFFIX}$/, 1]
    end

    def file_path(dir = nil)
      dir ||= DEFAULT_CREDENTIALS_DIR
      File.join(dir, service + BASEFILE_SUFFIX)
    end

    # parse a credentials file content
    def self.parse(input)
      if input.match /^\s*username\s*=\s*(\S+)\s*$/
        user = $1
      end

      if input.match /^\s*password\s*=\s*(\S+)\s*$/
        passwd = $1
      end

      return [ user,  passwd ]
    end

    # serialize the credentials for writing to a file
    def serialize
      "username=#{username}\npassword=#{password}\n"
    end

  end
end
