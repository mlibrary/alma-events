class MessageRouter
  def self.route(body, logger)
    begin
      parsed_body = JSON.parse(body)
    rescue
      logger.error("Invalid body: #{body}")
      parsed_body = []
    end
    if ReindexJobsGenerator.match?(parsed_body) && ENV.fetch("REINDEX_ON") == "true"
      logger.info("Matched Reindex Jobs Generator")
      ReindexJobsGenerator.new(data: parsed_body).run
    elsif DailyIndexingJobsGenerator.match?(parsed_body) && ENV.fetch("DAILY_INDEX_ON") == "true"
      logger.info("Daily Indexing Jobs Generator")
      DailyIndexingJobsGenerator.new(data: parsed_body).run
    else
      logger.info("Did not match anything")
    end
  end
end
