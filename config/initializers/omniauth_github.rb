Rails.application.config.middleware.use OmniAuth::Builder do
  scope = %w(
    user:email
  )
  config = Rails.application.secrets

  provider :github, config['github_key'], config['github_secret'], scope: scope
end
