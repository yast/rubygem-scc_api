# encoding: utf-8

require "fileutils"
require "pathname"
require "scc_api/logger"

module SccApi

  # TODO FIXME: add Yardoc comments
  class Credentials
    include Logger

    # the default location of credential files
    DEFAULT_CREDENTIALS_DIR = "/etc/zypp/credentials.d/"
    # default suffix
    BASEFILE_SUFFIX = "_credentials"

    attr_reader :username, :password
    attr_accessor :file

    def initialize(user, password, file = nil)
      @username = user
      @password = password
      @file = file
    end

    def self.read(file)
      content = File.read(file)

      user, passwd = parse(content)
      log.info("Reading credentials from #{file}")
      credentials = Credentials.new(user, passwd, file)
      log.debug("Read credentials: #{credentials}")
      credentials
    end

    # Write credentials to a file
    def write()
      raise "Invalid filename" if file.nil? || file.empty?
      filename = Pathname.new(file).absolute? ? file : File.join(DEFAULT_CREDENTIALS_DIR, file)

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
      "#<#{self.class}:#{sprintf("%0#16x", object_id)} @username=#{username.inspect}, @password=\"[FILTERED]\", @file=#{file.inspect}>"
    end

    private

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
