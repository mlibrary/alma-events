class JobQueued
  def call(worker, job, queue, redis_pool)
    Faraday.post("#{ENV.fetch("SIDEKIQ_SUPERVISOR_HOST")}/api/v1/jobs", {
      job_id: job["jid"],
      arguments: job["args"].to_json,
      job_class: job["class"],
      queue: queue
    })
    yield
  end
end
