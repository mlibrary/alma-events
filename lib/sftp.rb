require "net/sftp"
require "ed25519"
require "bcrypt_pbkdf"
class SFTP
  def initialize
    @user = ENV.fetch("ALMA_FILES_USER")
    @host = ENV.fetch("ALMA_FILES_HOST")
    @key = ENV.fetch("SSH_KEY_PATH")
    @sftp = Net::SFTP.start(@host, @user, key_data: [], keys: @key, keys_only: true)
  end

  # returns an array of items in a directory
  def ls(path = ".")
    @sftp.dir.glob(path, "**").filter_map { |x| "#{path}/#{x.name}" }
  end
end
