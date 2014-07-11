require 'test_helper'

class TopControllerTest < ActionController::TestCase
  test 'GET /' do
    get :index, trailing_slash: true
    assert { response.response_code == 200 }
  end
end
