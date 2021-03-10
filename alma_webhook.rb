require 'sinatra'
require 'json'

require './lib/message_validator'

get '/' do
  content_type :json
  { "challenge" => params["challenge"] }.to_json
end

post '/' do
  signature = request.env["X-Exl-Signature"] || request.env['HTTP_X_EXL_SIGNATURE']
  body = request.body.read
  if MessageValidator.valid?(body, signature)
    response.status = 200
  else
    response.status = 400
  end
  logger.info body
end

