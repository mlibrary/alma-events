require "sinatra"
require "json"
require "sidekiq"

require "./lib/message_validator"
require "./lib/sftp"
require "./lib/indexing_file"
require "./lib/indexing_jobs_generator"
require "./lib/message_router"

get "/" do
  content_type :json
  {"challenge" => params["challenge"]}.to_json
end

post "/" do
  signature = request.env["X-Exl-Signature"] || request.env["HTTP_X_EXL_SIGNATURE"]
  body = request.body.read
  if MessageValidator.valid?(body, signature)
    logger.info body
    response.status = 200
    MessageRouter.route(body, logger)
  else
    response.status = 400
    logger.error "invalid message"
  end
end

post "/send-dev-webhook-message" do
  if settings.environment == :development
    body = request.body.read
    logger.info("sent development mode webhook message with body: #{body}")
    MessageRouter.route(body, logger)
  else
    logger.error("Not in development mode")
    response.status = 500
  end
end
