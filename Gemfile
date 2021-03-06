source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', "5.1.0" # github: 'rails/rails'

gem 'mysql2', "0.3.18"
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails' #, '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails' #, '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'chronic_duration'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'nprogress-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', github: "rails/turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'react-rails'
gem 'sprockets-coffee-react'

gem 'material_design_lite-rails'

gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'git'
gem 'devise', github: "plataformatec/devise"
gem 'octokit'
gem 'sidekiq'
# gem 'sidekiq-cron'
gem 'omniauth'
gem 'omniauth-github'
gem 'dotenv-rails', :groups => [:development, :test]
gem 'kaminari'
gem 'aasm'

gem 'travis-yaml'
gem 'sinatra', github: "sinatra/sinatra"
gem 'colorize'

# Use Unicorn as the app server
# gem 'unicorn'
# gem 'thin'
gem 'puma'
#gem 'redis'
gem "redis", "~> 3.0" 

group :test do 
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
  end
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano3-puma'
  gem 'capistrano-rvm'
  gem 'capistrano-bundle'
  gem 'capistrano-sidekiq'
  gem 'foreman'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
end
