require 'test_helper'

class TopControllerTest < ActionController::TestCase
  test 'GET /' do
    s3_storage = Minitest::Mock.new
    s3_storage.expect(:each_metadata, []) do |prefix, &block|
      assert { prefix == Rails.application.config.artifact_root_path.to_s }
    end

    @controller.stub(:s3_storage, s3_storage) do
      get :index, trailing_slash: true
    end
    assert { response.response_code == 200 }
    s3_storage.verify
  end
end
