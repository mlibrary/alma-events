require 'sinatra'
require 'json'
require 'sidekiq'

require './lib/message_validator'
require './lib/indexing_jobs_generator.rb'
require './lib/message_router.rb'

get '/' do
  content_type :json
  { "challenge" => params["challenge"] }.to_json
end

post '/' do
  signature = request.env["X-Exl-Signature"] || request.env['HTTP_X_EXL_SIGNATURE']
  body = request.body.read
  if MessageValidator.valid?(body, signature)
    response.status = 200
    MessageRouter.route(body)
  else
    response.status = 400
    logger.error "invalid message"
  end
  logger.info body
end
