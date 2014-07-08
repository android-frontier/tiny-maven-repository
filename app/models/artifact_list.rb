class ArtifactList
  include Enumerable

  def initialize(root_path = Rails.application.config.artifact_root_path)
    @root_path = root_path

    @artifacts = []
    Dir.glob("#{root_path}/**/maven-metadata.xml").each do |xml|
      metadata = File.read(xml)
      @artifacts.push(Artifact.new(metadata))
    end
  end

  def each(&block)
    @artifacts.each(&block)
  end
end
