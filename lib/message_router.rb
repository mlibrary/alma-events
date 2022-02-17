class MessageRouter
  def self.route(body)
    if IndexingJobsGenerator.match?(body)
      IndexingJobsGenerator.new(body).run
    end
  end
end
