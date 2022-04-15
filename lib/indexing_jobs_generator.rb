class IndexingJobsGenerator
  def self.match?(data)
    data["action"] == "JOB_END" &&
      data["job_instance"]["name"] == alma_job_name &&
      data["job_instance"]["status"]["value"] == "COMPLETED_SUCCESS"
  end

  def initialize(data:, sftp: SFTP.new, logger: Logger.new($stdout), 
                 push_indexing_jobs: lambda do |job_name:,files:,solr_url:|  
                   Sidekiq::Client.push_bulk("class" => job_name,"args" => files.map { |x| [x, solr_url] })
                  end
                )
    @data = data
    @sftp = sftp
    @logger = logger
    @push_indexing_jobs = push_indexing_jobs
  end

  def actions 
    @actions ||= IndexingActions.new(files)
  end
  def files
    @files ||= @sftp.ls(alma_output_directory).filter do |file|
      file.match?(/#{@data["id"]}/)
    end
  end
end

class ReindexJobsGenerator < IndexingJobsGenerator
  def self.alma_job_name
    ENV.fetch("FULL_CATALOG_REINDEX_ALMA_JOB_NAME")
  end

  def run
    actions.each do |action|
      @logger.info action.summary
    end
    actions.each do |action|
      @push_indexing_jobs.call(job_name: action.job_name, files: action.files, solr_url: ENV.fetch("REINDEX_SOLR_URL"))
    end
  end

  private
  def date
    Date.parse(@data["time"]).strftime("%Y%d%m")
  end
  def alma_output_directory
    ENV.fetch("FULL_ALMA_FILES_PATH")
  end
end
