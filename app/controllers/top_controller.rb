class TopController < ApplicationController
  def index
    @artifacts = ArtifactList.new(s3_storage: s3_storage)
  end
end
