source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "sinatra"
gem "puma"
gem "sidekiq"
gem "faraday"
gem "rackup"

gem "sftp", github: "mlibrary/sftp"

group :development, :test do
  gem "debug"
  gem "rack-test"
  gem "rspec"
  gem "sinatra-contrib"
  gem "webmock"
  gem "simplecov"
  gem "standard"
  gem "climate_control"
end
