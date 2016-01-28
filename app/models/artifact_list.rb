class ArtifactList
  include Enumerable

  def initialize(root_path = Rails.application.config.artifact_root_path, s3_storage: S3Storage.new)
    @root_path = root_path

    @artifacts = []
    s3_storage.each_metadata(root_path.to_s) do |xml_key|
      metadata = s3_storage.get_object(xml_key)
      @artifacts.push(Artifact.new(metadata))
    end
  end

  def each(&block)
    @artifacts.each(&block)
  end
end
