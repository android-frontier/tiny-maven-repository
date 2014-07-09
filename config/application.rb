require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TinyMavenRepository
  class Application < Rails::Application
    config.autoload_paths << File.expand_path("../lib", __FILE__)

    site_config_file = Rails.root.join('config/site.yml')
    unless site_config_file.exist?
      site_config_file = Rails.root.join('config/site.yml.sample')
    end
    Rails.application.config.site = YAML.load_file(site_config_file).with_indifferent_access

    if Rails.application.secrets.x_sendfile_header
      config.action_dispatch.x_sendfile_header = Rails.application.secrets.x_sendfile_header
    end

    if Rails.application.secrets.artifact_root_path.present?
      config.artifact_root_path = Pathname.new(Rails.application.secrets.artifact_root_path).cleanpath
    else
      config.artifact_root_path = Rails.root.join('tmp', 'artifacts')
      config.artifact_root_path.mkpath
    end
  end
end
