class MessageValidator
  def self.valid?(request_body, exl_signature)
    hmac = OpenSSL::HMAC.new ENV["ALMA_WEBHOOK_SECRET"], OpenSSL::Digest.new("sha256")
    hmac.update request_body
    exl_signature == Base64.strict_encode64(hmac.digest)
  end
end
