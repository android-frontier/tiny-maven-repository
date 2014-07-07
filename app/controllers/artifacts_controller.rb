class ArtifactsController < ApplicationController
  def index

  end

  def show

  end

  def metadata

  end

  def publish
    redirect_to root_path, status: :ok, notice: 'artifact published'
  end
end
