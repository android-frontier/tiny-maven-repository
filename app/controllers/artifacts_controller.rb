class ArtifactsController < ApplicationController

  def index

  end

  def show
    open_for_reading(artifact_path) do |ins|
      send_file(ins)
    end
  rescue Errno::ENOENT
    render text: "File Not Found\n", status: 404
  end

  def publish
    open_for_writing(artifact_path) do |outs|
      IO.copy_stream(request.body_stream, outs)
    end

    redirect_to root_path, status: :ok, notice: 'artifact published'
  end

  private

  def artifact_path
    # FIXME: avoid directory traversals
    artifact_path = params.require(:artifact_path)
    filename = params.require(:filename)
    Rails.application.config.artifact_root_path.join(artifact_path, filename)
  end

  def open_for_reading(path, &block)
    File.open(path, "r", &block)
  end

  def open_for_writing(path, &block)
    FileUtils.mkdir_p(path.dirname)
    File.open(path, "wb", &block)
  end
end
