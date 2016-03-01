Rails.application.config.middleware.use OmniAuth::Builder do
  scope = %w(
    user:email
  )
  config = Rails.application.secrets

  provider :github, config['github_key'], config['github_secret'], scope: scope,
    client_options: {
      site: config['github_site'],
      authorize_url: config['github_authorize_url'],
      token_url: config['github_token_url'],
    }

end
