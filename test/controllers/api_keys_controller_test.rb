require "test_helper"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_keys_index_url
    assert_response :success
  end

  test "should get toggle" do
    get api_keys_toggle_url
    assert_response :success
  end
end
