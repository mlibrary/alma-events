require "sinatra"
require "json"
require "sidekiq"
require "sftp"
require "faraday"
require "byebug" if settings.environment == :development

require "./lib/message_validator"
require "./lib/indexing_action"
require "./lib/indexing_jobs_generator"
require "./lib/message_router"
require "./lib/sidekiq_middleware"

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add JobQueued if ENV.fetch("SUPERVISOR_ON") == "true"
  end
end

SFTP.configure do |config|
  config.user = ENV.fetch("ALMA_FILES_USER")
  config.host = ENV.fetch("ALMA_FILES_HOST")
  config.key_path = ENV.fetch("SSH_KEY_PATH")
end

get "/" do
  content_type :json
  {"challenge" => params["challenge"]}.to_json
end

post "/" do
  signature = request.env["X-Exl-Signature"] || request.env["HTTP_X_EXL_SIGNATURE"]
  body = request.body.read
  if MessageValidator.valid?(body, signature)
    logger.info body
    MessageRouter.route(body, logger)
    response.status = 200
  else
    response.status = 400
    logger.error "invalid message"
  end
  response.body = {}
end

post "/send-dev-webhook-message" do
  if settings.environment == :development
    body = request.body.read
    logger.info("sent development mode webhook message with body: #{body}")
    MessageRouter.route(body, logger)
    response.status = 200
  else
    logger.error("Not in development mode")
    response.status = 500
  end
  response.body = {}
end
