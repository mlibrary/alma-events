class JobQueued
  def call(worker, job, queue, redis_pool)
    if ENV.fetch("SOLRCLOUD_ON") == "true"
      response = Faraday.post("#{ENV.fetch("SIDEKIQ_SUPERVISOR_HOST")}/api/v1/jobs", {
        job_id: job["jid"],
        arguments: job["args"].to_json,
        job_class: job["class"],
        queue: queue
      })
    end
    yield
  end
end
