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
      status = if s3_storage.exist?(artifact_path)
                 200
               else
                 404
               end
      head status, connection: 'close'
      return
    end

    path = artifact_path
    begin
      send_data s3_storage.get_object(path)
    rescue Aws::S3::Errors::NoSuchKey
      @files = files(path)
      if @files.empty?
        render text: "File Not Found\n", status: 404
      else
        unless request.original_fullpath.end_with?('/')
          return redirect_to "#{request.original_fullpath}/"
        end
        render :index
      end
    end
  end

  def publish
    path = artifact_path
    s3_storage.put_object(artifact_path, request.body_stream)

    render nothing: true, status: 204
  end

  def delete
    # TODO: too much logic in controllers!
    path = artifact_path
    # path is something like "/path/to/com/cookpad/android/pantryman/1.0.0"

    # remove it from metadata first
    version = File.basename(path)
    unless /\d/ =~ version
      return render text: "Bad Request: #{path}", status: 400
    end

    artifacts_dir = File.dirname(path)

    metadata_file = File.join(artifacts_dir, 'maven-metadata.xml')
    artifact = Artifact.new(s3_storage.get_object(metadata_file))
    artifact.remove_version(version)
    if artifact.empty?
      s3_storage.rmtree(artifacts_dir)
    else
      artifact.save(s3_storage, metadata_file)

      s3_storage.rmtree(path)
    end

    redirect_to root_path, notice: 'artifact deleted'
  end

  private

  def files(dir)
    s3_storage.list_artifacts(dir.to_s)
  end

  # @return [Pathname]
  def artifact_path
    root = Rails.application.config.artifact_root_path
    path = root.join(params.require(:artifact_path))
    path.cleanpath.to_s.start_with?(root.to_s + "/") ? path.to_s : nil
  end
end
