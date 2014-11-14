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
  end

  teardown do
    FileUtils.rmtree(root)
  end

  test 'GET /' do
    get :index, trailing_slash: true
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path' do
    get :show, artifact_path: file
    assert { response.response_code == 200 }
    assert { response.body == 'Hello, world!' }
  end

  test 'HEAD /artifacts/:artifact_path' do
    head :show, artifact_path: file
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path (not found)' do
    get :show, artifact_path: non_existing_file
    assert { response.response_code == 404 }
  end

  test 'HEAD /artifacts/:artifact_path (not found)' do
    head :show, artifact_path: non_existing_file
    assert { response.response_code == 404 }
  end

  test 'PUT /artifacts/:artifact_path' do
    put :publish, { artifact_path: file }

    assert { response.response_code == 204 }
  end

  test 'DELETE /artifact/:artifact_path (one)' do
    delete :delete, { artifact_path: file2 }

    assert { response.response_code == 302 }

    assert {  File.exist?(root.join(file)) }
    assert { !File.exist?(root.join(file2)) }
    assert { Artifact.new(File.read(root.join(metadata_file))).version == "1.0.0"}
  end

  test 'DELETE /artifact/:artifact_path (all)' do
    delete :delete, { artifact_path: file }
    delete :delete, { artifact_path: file2 }

    assert { response.response_code == 302 }

    assert { !File.exist?(root.join(file)) }
    assert { !File.exist?(root.join(file2)) }
    assert { !File.exist?(root.join(metadata_file)) }
  end

end
