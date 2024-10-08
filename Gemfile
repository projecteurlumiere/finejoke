source "https://rubygems.org"

ruby "3.3.1"

group :default do
  gem "importmap-rails"
  gem "pg", "~> 1.1"
  gem "rails", "~> 7.1.3", ">= 7.1.3.2"
  gem "sprockets-rails"
  gem "stimulus-rails"
  gem "turbo-rails"
  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem "tzinfo-data", platforms: %i[windows jruby]

  gem "activerecord-postgres_pub_sub"
  gem "autoprefixer-rails"
  # Reduces boot times through caching; required in config/boot.rb
  gem "bootsnap", require: false
  gem "devise"
  gem "devise-guests"
  gem "falcon"
  gem "kaminari"
  gem "normalize-rails"
  gem "pundit"
  gem "rails-i18n"
  gem "ruby-openai"
  gem "sassc-rails"
  gem "terser"

  # # Build JSON APIs with ease [https://github.com/rails/jbuilder]
  # gem "jbuilder"

  # # Use Redis adapter to run Action Cable in production
  # gem "redis", ">= 4.0.1"

  # # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
  # gem "kredis"

  # # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
  # gem "bcrypt", "~> 3.1.7"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]

  gem "dotenv", groups: [:development, :test]
end

group :development do
  gem "i18n_generators"
  gem "letter_opener"
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  gem "async-io" # necessary to run falcon-capybara
  gem "falcon-capybara"
  gem "rspec-rails", "~> 6.1.0"
end
