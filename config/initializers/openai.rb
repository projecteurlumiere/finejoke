OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", "")
  # config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID", "")
  config.request_timeout = 15 # seconds
  config.log_errors = true if Rails.env.development?
end
