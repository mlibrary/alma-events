class MessageRouter
  def self.route(body, logger)
    begin
      parsed_body = JSON.parse(body)
    rescue
      logger.error("Invalid body: #{body}")
      parsed_body = []
    end
    if IndexingJobsGenerator.match?(parsed_body)
      logger.info("Matched Indexing Jobs Generator")
      IndexingJobsGenerator.new(parsed_body).run
    else
      logger.info("Did not match anything")
    end
  end
end
