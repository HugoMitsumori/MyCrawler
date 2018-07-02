# User
class User
  include ActiveModel::Model
  attr_accessor :code, :password

  def encrypted
    crypt = ActiveSupport::MessageEncryptor.new([ENV['CRYPT_KEY']].pack('H*'))
    crypt.encrypt_and_sign("#{@code} #{@password}")
  end

  def self.decrypt(value)
    crypt = ActiveSupport::MessageEncryptor.new([ENV['CRYPT_KEY']].pack('H*'))
    crypt.decrypt_and_verify(value)
  end
end
