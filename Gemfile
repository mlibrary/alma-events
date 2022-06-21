source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "sinatra"
gem "puma"
gem "sidekiq"

source "https://rubygems.pkg.github.com/mlibrary" do
  gem "sftp"
end

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "rack-test"
  gem "rspec"
  gem "sinatra-contrib"
  gem "webmock"
  gem "simplecov"
  gem "standard"
end
