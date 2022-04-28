class IndexingActions
  def initialize(files)
    @list = [
      IndexingNewAction.new(files),
      IndexingDeleteAction.new(files)
    ].reject { |x| x.empty? }
  end

  def each(&block)
    @list.each do |item|
      block.call(item)
    end
  end
end

class IndexingAction
  attr_reader :files
  def initialize(files)
    @files = files&.filter do |file|
      file.match?(file_name_pattern)
    end || []
  end

  def empty?
    @files.empty?
  end

  def summary
    "#{@files.count} file(s) for #{job_name} job"
  end
end

class IndexingNewAction < IndexingAction
  def job_name
    "IndexIt"
  end

  def file_name_pattern
    /_new\.tar/
  end
end

class IndexingDeleteAction < IndexingAction
  def job_name
    "DeleteIt"
  end

  def file_name_pattern
    /_delete\.tar/
  end
end
