require_relative "../spec_helper"
describe ReindexJobsGenerator do
  before(:each) do
    @data = JSON.parse(fixture("publishing_job_response.json"))
    @job_id_from_data = @data["id"]
    @files = [
      "file_#{@job_id_from_data}_new.tar.gz",
      "file_#{@job_id_from_data}_delete.tar.gz",
      "file_#{@job_id_from_data}_new_22.tar.gz",
      "file_#{@job_id_from_data}_delete_1.tar.gz",
      "file_new.tar.gz"
    ]
    @sftp_double = instance_double(SFTP::Client, ls: @files)
    @logger_double = instance_double(Logger, info: nil)
    @push_bulk_double = double("SidekiqClient", push_bulk: nil)
    @push_indexing_jobs = lambda do |job_name:, queue:, files:, solr_url:|
      @push_bulk_double.push_bulk(job_name, queue, files, solr_url)
    end
  end
  context ".match?" do
    it "matches the correct job" do
      expect(described_class.match?(@data)).to eq(true)
    end
    it "does not match when it should not match" do
      @data["job_instance"]["name"] = "Not the correct job name"
      expect(described_class.match?(@data)).to eq(false)
    end
  end
  context "initialize" do
    it "raises ArgumentError if neither data nor job_id are present" do
      expect { described_class.new(sftp: @sftp_double, logger: @logger_double) }.to raise_error(ArgumentError, "missing keyword: :data or :job_id")
    end
  end
  context ".alma_job_name" do
    it "returns the correct environment variable" do
      expect(described_class.alma_job_name).to eq(ENV.fetch("FULL_CATALOG_REINDEX_ALMA_JOB_NAME"))
    end
  end

  subject do
    described_class.new(data: @data, sftp: @sftp_double, logger: @logger_double, push_indexing_jobs: @push_indexing_jobs)
  end
  context "#job_id" do
    it "when data is present it returns the job id from the data" do
      expect(subject.job_id).to eq(@job_id_from_data)
    end
    it "when data and job_id are present default to data" do
      expect(described_class.new(data: @data, sftp: @sftp_double, logger: @logger_double, job_id: "11111").job_id).to eq(@job_id_from_data)
    end
    it "when job_id but not data is present, returns the job_id" do
      expect(described_class.new(sftp: @sftp_double, logger: @logger_double, job_id: "11111").job_id).to eq("11111")
    end
  end
  context "files" do
    it "returns the list of files that matches the job_id" do
      files = ["file_#{@job_id_from_data}_new.tar.gz", "file_new.tar.gz"]
      allow(@sftp_double).to receive(:ls).and_return(files)
      expect(subject.files).to eq([files[0]])
    end
  end
  context "run" do
    it "logs actions summary" do
      expect(@logger_double).to receive(:info).with("2 file(s) for IndexIt job")
      expect(@logger_double).to receive(:info).with("2 file(s) for DeleteIt job")
      subject.run
    end
    it "sends the correct arguments to push_indexing_jobs" do
      expect(@push_bulk_double).to receive(:push_bulk).with("IndexIt", "reindex", [@files[0], @files[2]], ENV.fetch("REINDEX_SOLR_URL"))
      expect(@push_bulk_double).to receive(:push_bulk).with("DeleteIt", "reindex", [@files[1], @files[3]], ENV.fetch("REINDEX_SOLR_URL"))
      subject.run
    end
  end
end
describe DailyIndexingJobsGenerator do
  before(:each) do
    @data = JSON.parse(fixture("publishing_job_response.json"))
    @data["job_instance"]["name"] = ENV.fetch("DAILY_CATALOG_INDEX_ALMA_JOB_NAME")
    @job_id_from_data = @data["id"]
    @files = [
      "file_#{@job_id_from_data}_new.tar.gz",
      "file_#{@job_id_from_data}_delete.tar.gz",
      "file_new.tar.gz"
    ]
    @sftp_double = instance_double(SFTP::Client, ls: @files)
    @logger_double = instance_double(Logger, info: nil)
    @push_bulk_double = double("SidekiqClient", push_bulk: nil)
    @push_indexing_jobs = lambda do |job_name:, queue:, files:, solr_url:|
      @push_bulk_double.push_bulk(job_name, queue, files, solr_url)
    end
  end
  context ".match?" do
    it "matches the correct job" do
      expect(described_class.match?(@data)).to eq(true)
    end
    it "does not match when it should not match" do
      @data["job_instance"]["name"] = "Not the correct job name"
      expect(described_class.match?(@data)).to eq(false)
    end
  end
  subject do
    described_class.new(data: @data, sftp: @sftp_double, logger: @logger_double, push_indexing_jobs: @push_indexing_jobs)
  end
  context "run" do
    it "logs actions summary" do
      expect(@logger_double).to receive(:info).with("1 file(s) for IndexIt job")
      expect(@logger_double).to receive(:info).with("1 file(s) for DeleteIt job")
      subject.run
    end
    it "sends the correct arguments to push_indexing_jobs" do
      expect(@push_bulk_double).to receive(:push_bulk).with("IndexIt", "default", [@files[0]], ENV.fetch("MACC_PRODUCTION_SOLR_URL"))
      expect(@push_bulk_double).to receive(:push_bulk).with("IndexIt", "default", [@files[0]], ENV.fetch("HATCHER_PRODUCTION_SOLR_URL"))
      expect(@push_bulk_double).to receive(:push_bulk).with("DeleteIt", "default", [@files[1]], ENV.fetch("MACC_PRODUCTION_SOLR_URL"))
      expect(@push_bulk_double).to receive(:push_bulk).with("DeleteIt", "default", [@files[1]], ENV.fetch("HATCHER_PRODUCTION_SOLR_URL"))
      subject.run
    end
  end
end
