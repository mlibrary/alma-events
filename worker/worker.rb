require "sidekiq"
class IndexIt
  include Sidekiq::Job
  def perform(file, solr_url)
    puts "#{file} IndexIt into #{solr_url}"
  end
end

class DeleteIt
  include Sidekiq::Job
  def perform(file, solr_url)
    puts "#{file} DeleteIt at #{solr_url}"
  end
end
