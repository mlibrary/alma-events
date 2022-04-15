require_relative "../spec_helper"
describe ReindexJobsGenerator do
  before(:each) do
    @data = JSON.parse(fixture("publishing_job_response.json"))
    @sftp_double = instance_double(SFTP, ls: "")
    @logger_double = instance_double(Logger, info: nil)
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
    described_class.new(data: @data, sftp: @sftp_double, logger: @logger_double)
  end

end
