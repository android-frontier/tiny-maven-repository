class ArtifactsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: %i(publish)

  def index
    unless request.original_fullpath.end_with?('/')
      return redirect_to "#{request.original_fullpath}/"
    end

    @files = files(Rails.application.config.artifact_root_path)
  end

  def show
    if request.head?
      status = if artifact_path.exist?
                 200
               else
                 404
               end
      head status, connection: 'close'
      return
    end

    path = artifact_path
    if path.try(:directory?)
      unless request.original_fullpath.end_with?('/')
        return redirect_to "#{request.original_fullpath}/"
      end

      @files = files(path)
      render :index
    else
      send_file(path)
    end
  rescue ActionController::MissingFile
    render text: "File Not Found\n", status: 404
  end

  def publish
    path = artifact_path
    open_for_writing(path) do |outs|
      IO.copy_stream(request.body_stream, outs)
    end

    redirect_to root_path, status: :ok, notice: 'artifact published'
  rescue
    render text: 'Bad Request', status: 400
  end

  private

  def files(dir)
    Dir.foreach(dir).sort.find_all do |item|
      !item.start_with?('.')
    end
  end

  # @return [Pathname]
  def artifact_path
    root = Rails.application.config.artifact_root_path
    path = root.join(params.require(:artifact_path))
    path.cleanpath.to_s.start_with?(root.to_s + "/") ? path : nil
  end

  def open_for_writing(path, &block)
    FileUtils.mkdir_p(path.dirname)
    File.open(path, "wb", &block)
  end
end
