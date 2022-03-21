require_relative "../spec_helper"
describe IndexingJobsGenerator do
  before(:each) do
    @data = JSON.parse(fixture("publishing_job_response.json"))
    @sftp_double = instance_double(SFTP,ls: '')
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
    described_class.new(@data, @sftp_double, @logger_double)
  end
  context "new_files" do
    it "matches appropriate file names" do
      allow(@sftp_double).to receive(:ls).and_return(["bib_search_2022021017_16501890430006381_new.tar.gz","bib_search_2022021017_16501890430006381_delete.tar.gz","just wrong file name"])
      expect(subject.new_files).to eq(["bib_search_2022021017_16501890430006381_new.tar.gz"])
    end
  end
  context "delete_files" do
    it "matches appropriate file names" do
      allow(@sftp_double).to receive(:ls).and_return(["bib_search_2022021017_16501890430006381_new.tar.gz","bib_search_2022021017_16501890430006381_delete.tar.gz","just wrong file name"])
      expect(subject.delete_files).to eq(["bib_search_2022021017_16501890430006381_delete.tar.gz"])
    end
  end

end
