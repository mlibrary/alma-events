class IndexingFile
  attr_reader :file_path
  def self.for(file_path)
    case file_path
    when /_new\.tar/
      IndexingNewFile.new(file_path)
    when /_delete\.tar/
      IndexingDeleteFile.new(file_path)
    end
  end

  def initialize(file_path)
    @file_path = file_path
  end

  def to_s
    @file_path
  end
end

class IndexingNewFile < IndexingFile
  def job_name
    "IndexIt"
  end
end

class IndexingDeleteFile < IndexingFile
  def job_name
    "DeleteIt"
  end
end
