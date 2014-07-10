class Artifact
  attr_reader :metadata

  def initialize(metadata)
    @metadata = Nokogiri.parse(metadata)
  end

  def group_id
    @metadata.css('metadata groupId').first.text
  end

  def artifact_id
    @metadata.css('metadata artifactId').first.text
  end

  def version
    @metadata.css('metadata versioning versions version').last.text
  end

  def as_dependency
    "#{group_id}:#{artifact_id}:#{version}"
  end
end
