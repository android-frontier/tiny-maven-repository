require 'test_helper'

class ArtifactsControllerTest < ActionController::TestCase
  root = Rails.application.config.artifact_root_path

  test 'GET /' do
    FileUtils.mkdir_p(root)

    get :index, trailing_slash: true
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path' do
    FileUtils.mkdir_p(root.join('com/example'))
    File.write(root.join('com/example/artifact.txt'), 'Hello, world!')

    get :show, artifact_path: 'com/example/artifact.txt'
    assert { response.response_code == 200 }
    assert { response.body == 'Hello, world!' }
  end

  test 'HEAD /artifacts/:artifact_path' do
    FileUtils.mkdir_p(root.join('com/example'))
    File.write(root.join('com/example/artifact.txt'), 'Hello, world!')

    head :show, artifact_path: 'com/example/artifact.txt'
    assert { response.response_code == 200 }
  end

  test 'GET /artifacts/:artifact_path (not found)' do
    get :show, artifact_path: 'com/example/not/found/artifact.txt'
    assert { response.response_code == 404 }
  end

  test 'HEAD /artifacts/:artifact_path (not found)' do
    head :show, artifact_path: 'com/example/not/found/artifact.txt'
    assert { response.response_code == 404 }
  end

  test 'PUT /artifacts/:artifact_path' do
    put :publish, { artifact_path: 'com/example/artifact.txt' }

    assert { response.response_code == 200 }
  end
end
