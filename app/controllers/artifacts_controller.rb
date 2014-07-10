class ArtifactsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: %i(publish)

  def index
  end

  def show
    path = artifact_path
    if path
      send_file(path)
    else
      render text: "File Not Found\n", status: 404
    end
  rescue ActionController::MissingFile
    render text: "File Not Found\n", status: 404
  end

  def publish
    path = artifact_path
    if path
      open_for_writing(path) do |outs|
        IO.copy_stream(request.body_stream, outs)
      end

      redirect_to root_path, status: :ok, notice: 'artifact published'
    else
      render text: 'bad request', status: 400
    end
  end

  private

  def artifact_path
    artifact_path = params.require(:artifact_path)
    filename = params.require(:filename)
    root = Rails.application.config.artifact_root_path

    path = root.join(artifact_path, filename)
    path.cleanpath.to_s.start_with?(root.to_s + "/") ? path : nil
  end

  def open_for_writing(path, &block)
    FileUtils.mkdir_p(path.dirname)
    File.open(path, "wb", &block)
  end
end
