require 'test_helper'

class ArtifactsControllerTest < ActionController::TestCase
  root = Rails.application.config.artifact_root_path
  dir = 'com/example/1.0.0'
  dir2 = 'com/example/2.0.1'

  file = "#{dir}/artifact.txt"
  file2 = "#{dir2}/artifact.txt"

  non_existing_file = "#{dir}/non_existing_artifact.txt"
  metadata_file = 'com/example/maven-metadata.xml'

  setup do
    FileUtils.mkdir_p(root.join(dir))
    FileUtils.mkdir_p(root.join(dir2))

    File.write(root.join(file), 'Hello, world!')
    File.write(root.join(file2), 'Hello, world!')
    FileUtils.copy_file('test/fixtures/maven-metadata.xml', root.join(metadata_file))

    @s3_storage = Minitest::Mock.new
  end

  teardown do
    @s3_storage.verify
    FileUtils.rmtree(root)
  end

  test 'GET /' do
    @s3_storage.expect(:list_artifacts, [], [root.to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      get :index, trailing_slash: true
    end
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path' do
    @s3_storage.expect(:get_object, 'Hello, world!', [root.join(file).to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      get :show, artifact_path: file
    end
    assert { response.response_code == 200 }
    assert { response.body == 'Hello, world!' }
  end

  test 'HEAD /artifacts/:artifact_path' do
    @s3_storage.expect(:exist?, true, [root.join(file).to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      head :show, artifact_path: file
    end
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path (not found)' do
    @s3_storage.expect(:get_object, nil) do |path|
      assert { path == root.join(non_existing_file).to_s }
      raise Aws::S3::Errors::NoSuchKey.new(nil, 'No such key')
    end
    @s3_storage.expect(:list_artifacts, [], [root.join(non_existing_file).to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      get :show, artifact_path: non_existing_file
    end
    assert { response.response_code == 404 }
  end

  test 'HEAD /artifacts/:artifact_path (not found)' do
    @s3_storage.expect(:exist?, false, [root.join(non_existing_file).to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      head :show, artifact_path: non_existing_file
    end
    assert { response.response_code == 404 }
  end

  test 'PUT /artifacts/:artifact_path' do
    @s3_storage.expect(:put_object, nil) do |path, io|
      assert { path == root.join(file).to_s }
      assert { io.respond_to?(:read) }
    end

    @controller.stub(:s3_storage, @s3_storage) do
      put :publish, { artifact_path: file }
    end

    assert { response.response_code == 204 }
  end

  test 'DELETE /artifact/:artifact_path (one)' do
    @s3_storage.expect(:get_object, File.read('test/fixtures/maven-metadata.xml'), [root.join(metadata_file).to_s])
    @s3_storage.expect(:put_object, nil) do |path, string_io|
      assert { path == root.join(metadata_file).to_s }
      assert { Artifact.new(string_io.string).version == '1.0.0' }
    end
    @s3_storage.expect(:put_object, nil, [root.join("#{metadata_file}.md5").to_s, StringIO])
    @s3_storage.expect(:put_object, nil, [root.join("#{metadata_file}.sha1").to_s, StringIO])
    @s3_storage.expect(:rmtree, nil, [root.join(dir2).to_s])

    @controller.stub(:s3_storage, @s3_storage) do
      delete :delete, { artifact_path: dir2 }
    end

    assert { response.response_code == 302 }
  end

  test 'DELETE /artifact/:artifact_path (all)' do
    # Delete 1.0.0
    @s3_storage.expect(:get_object, File.read('test/fixtures/maven-metadata.xml'), [root.join(metadata_file).to_s])
    removed_metadata = nil
    @s3_storage.expect(:put_object, nil) do |path, string_io|
      assert { path == root.join(metadata_file).to_s }
      assert { Artifact.new(string_io.string).version == '2.0.1' }
      removed_metadata = string_io.string
    end
    @s3_storage.expect(:put_object, nil, [root.join("#{metadata_file}.md5").to_s, StringIO])
    @s3_storage.expect(:put_object, nil, [root.join("#{metadata_file}.sha1").to_s, StringIO])
    @s3_storage.expect(:rmtree, nil, [root.join(dir).to_s])
    @controller.stub(:s3_storage, @s3_storage) do
      delete :delete, { artifact_path: dir }
    end

    # Delete 2.0.1
    @s3_storage.expect(:get_object, removed_metadata, [root.join(metadata_file).to_s])
    @s3_storage.expect(:rmtree, nil, [root.join(dir).parent.to_s])
    @controller.stub(:s3_storage, @s3_storage) do
      delete :delete, { artifact_path: dir2 }
    end

    assert { response.response_code == 302 }
  end
end
