class IndexingJobsGenerator
  def self.match?(data)
    data["action"] == "JOB_END" &&
      data["job_instance"]["name"] == job_name &&
      data["job_instance"]["status"]["value"] == "COMPLETED_SUCCESS"
  end
  attr_reader :files
  def initialize(data:, sftp: SFTP.new, logger: Logger.new(STDOUT))
    @data = data
    @sftp = sftp
    @files = files
    @logger = logger
  end

  def run
    @logger.info("#{new_files.count} new files; #{delete_files.count} delete files")
    if new_files.any?
      Sidekiq::Client.push_bulk("class" => "IndexIt", "args" => new_files.map { |x| [x.to_s] })
    end
    if delete_files.any?
      Sidekiq::Client.push_bulk("class" => "DeleteIt", "args" => delete_files.map { |x| [x.to_s] })
    end
  end

  def new_files
    @files.filter do |file|
      file.to_s.match?(/_new\.tar/)
    end
  end

  def delete_files
    @files.filter do |file|
      file.to_s.match?(/_delete\.tar/)
    end
  end

  private

  def files
    @sftp.ls(alma_output_directory).filter_map do |file|
      IndexingFile.for(file) if file.match?(/#{@data["id"]}/)
    end
  end
end

class ReindexJobsGenerator < IndexingJobsGenerator
  def self.job_name
    ENV.fetch("CATALOG_INDEXING_ALMA_JOB_NAME")
  end

  private

  def alma_output_directory
    ENV.fetch("CATALOG_INDEXING_DIRECTORY")
  end
end
