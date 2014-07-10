module ApplicationHelper
  def site_name
    Rails.application.secrets.site['name']
  end

  def site_url
    Rails.application.secrets.site['url']
  end

  def site_maven_repository_url
    Rails.application.secrets.site['maven_repository_url']
  end
end
