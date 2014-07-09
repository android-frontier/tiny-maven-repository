module ApplicationHelper
  def site_name
    Rails.application.config.site[:name]
  end

  def site_url
    Rails.application.config.site[:url]
  end

  def site_maven_repository_url
    Rails.application.config.site[:maven_repository_url]
  end
end
