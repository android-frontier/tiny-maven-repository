class TopController < ApplicationController
  def index
    @artifacts = ArtifactList.new
  end
end
