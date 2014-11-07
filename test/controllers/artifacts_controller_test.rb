require 'test_helper'

class ArtifactsControllerTest < ActionController::TestCase
  root = Rails.application.config.artifact_root_path
  dir = 'com/example/1.0.0'
  file = 'com/example/1.0.0/artifact.txt'
  non_existing_file = 'com/example/non_existing_artifact.txt'
  metadata_file = 'com/example/maven-metadata.xml'

  setup do
    FileUtils.mkdir_p(root.join(dir))
    File.write(root.join(file), 'Hello, world!')
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

    assert { response.response_code == 302 }
  end

  test 'DELETE /artifact/:artifact_path' do
    delete :delete, { artifact_path: file }

    assert { response.response_code == 302 }

    assert { !File.exist?(root.join(file)) }
  end
end
