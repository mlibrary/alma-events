class IndexingJobsGenerator
  def self.match?(data)
    data["action"] == "JOB_END" && data["job_instance"]["name"] == "Publishing Platform Job Search publish" && data["job_instance"]["status"]["value"] == "COMPLETED_SUCCESS"
  end
  attr_reader :files
  def initialize(data, sftp = SFTP.new)
    @data = data
    @sftp = sftp
    @files = files
  end
  def run
    if new_files.count > 0
      Sidekiq::Client.push_bulk('class' => 'IndexIt', 'args' => new_files.map{|x| [x]})
    end
    if delete_files.count > 0
      Sidekiq::Client.push_bulk('class' => 'RemoveIt', 'args' => delete_files.map{|x| [x]})
    end
  end

  def new_files
    @files.filter do |file|
      file.match?(/_new\.tar/)
    end
  end
  def delete_files
    @files.filter do |file|
      file.match?(/_delete\.tar/)
    end
  end
  private
  def files
    @sftp.ls("bib_search").filter do |file|
      file.match?(/#{@data["id"]}/)
    end
  end
end

class SFTP
  def initialize
    @user = 'alma'
    @host = 'sftp'
  end
  #returns an array of items in a directory
  def ls(path="")
    array = ["sftp", "-b", "-",  "#{@user}@#{@host}", 
      "<<<", "$'@ls #{path}'"]
    command = array.join(" ")
    `bash -c \"#{command}\"`.split("\n").map{|x| x.strip}
  end
end
