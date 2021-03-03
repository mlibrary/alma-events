require 'openssl'
require 'base64'
require 'json'
require 'spec_helper'
describe "requests" do
  include Rack::Test::Methods
  context "get /webhook?challenge=somestring" do
    it "returns the challenge param" do
      get "/?challenge=45ab36" 
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq({challenge: "45ab36"}.to_json)
      expect(last_response.headers["Content-type"]).to eq("application/json")
    end
  end
  context "post /" do
    before(:each) do
      @body = {thing: 'stuff', what: 'what'}.to_json
    end
    it "responds OK to correct signature" do
      hmac = OpenSSL::HMAC.new(ENV.fetch("ALMA_WEBHOOK_SECRET"), 'sha256')
      hmac << @body
      signature = Base64.strict_encode64(hmac.digest)

      post "/", @body, "CONTENT_TYPE" => "application/json", "X-Exl-Signature" => signature
      expect(last_response.status).to eq(200)
    end
    it "responds OK to correct signature and alternature signature header" do
      hmac = OpenSSL::HMAC.new(ENV.fetch("ALMA_WEBHOOK_SECRET"), 'sha256')
      hmac << @body
      signature = Base64.strict_encode64(hmac.digest)

      post "/", @body, "CONTENT_TYPE" => "application/json", "HTTP_X_EXL_SIGNATURE" => signature
      expect(last_response.status).to eq(200)
    end
    it "responds with an error if the signature doesn't match" do
      post "/", @body, "CONTENT_TYPE" => "application/json", "X-Exl-Signature" => "blah"
      expect(last_response.status).to eq(400)
    end
  end
end
