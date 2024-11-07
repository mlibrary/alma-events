class IndexingJobsGenerator
  attr_reader :job_id
  def self.match?(data)
    data["action"] == "JOB_END" &&
      data["job_instance"]["name"] == alma_job_name &&
      ["COMPLETED_SUCCESS", "COMPLETED_FAILED"].include?(data["job_instance"]["status"]["value"])
  end

  def initialize(data: nil, job_id: nil, sftp: SFTP.client, logger: Logger.new($stdout),
    push_indexing_jobs: lambda do |job_name:, queue:, files:, solr_url:|
                          Sidekiq::Client.push_bulk("class" => job_name, "queue" => queue, "args" => files.map { |x| [x, solr_url] })
                        end)
    @job_id = data&.dig("id") || job_id
    raise ArgumentError, "missing keyword: :data or :job_id" if @job_id.nil?
    @sftp = sftp
    @logger = logger
    @push_indexing_jobs = push_indexing_jobs
  end

  def actions
    @actions ||= IndexingActions.new(files)
  end

  def files
    @files ||= @sftp.ls(alma_output_directory).filter do |file|
      file.match?(/#{@job_id}/)
    end
  end
end

class ReindexJobsGenerator < IndexingJobsGenerator
  def self.alma_job_name
    ENV.fetch("FULL_CATALOG_REINDEX_ALMA_JOB_NAME")
  end

  def queue
    "reindex"
  end

  def run
    actions.each do |action|
      @logger.info action.summary
    end
    actions.each do |action|
      @push_indexing_jobs.call(job_name: action.job_name, queue: queue, files: action.files, solr_url: ENV.fetch("REINDEX_SOLR_URL"))
    end
  end

  private

  def alma_output_directory
    ENV.fetch("FULL_ALMA_FILES_PATH")
  end
end

class DailyIndexingJobsGenerator < IndexingJobsGenerator
  def self.alma_job_name
    ENV.fetch("DAILY_CATALOG_INDEX_ALMA_JOB_NAME")
  end

  def queue
    "default"
  end

  def run
    actions.each do |action|
      @logger.info action.summary
    end
    actions.each do |action|
      if ENV.fetch("SOLRCLOUD_ON") == "true"
        @push_indexing_jobs.call(job_name: action.job_name, queue: queue, files: action.files, solr_url: ENV.fetch("LIVE_SOLR_URL"))
      else
        @push_indexing_jobs.call(job_name: action.job_name, queue: queue, files: action.files, solr_url: ENV.fetch("HATCHER_PRODUCTION_SOLR_URL"))
        @push_indexing_jobs.call(job_name: action.job_name, queue: queue, files: action.files, solr_url: ENV.fetch("MACC_PRODUCTION_SOLR_URL"))
      end
    end
  end

  private

  def alma_output_directory
    ENV.fetch("DAILY_ALMA_FILES_PATH")
  end
end
