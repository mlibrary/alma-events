require 'sidekiq'
class IndexIt
  include Sidekiq::Job
  def perform(file)
    puts file
  end
end
