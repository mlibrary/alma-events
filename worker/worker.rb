require "sidekiq"
class IndexIt
  include Sidekiq::Job
  def perform(file)
    puts "IndexIt"
    puts file
  end
end

class DeleteIt
  include Sidekiq::Job
  def perform(file)
    puts "DeleteIt"
    puts file
  end
end
