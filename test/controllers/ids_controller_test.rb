require 'test_helper'

class IdsControllerTest < ActionController::TestCase
  test "should get grupo" do
    get :grupo
    assert_response :success
  end

  test "should get banco" do
    get :banco
    assert_response :success
  end

end
