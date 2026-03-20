require "test_helper"

class WebAccessKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get web_access_keys_index_url
    assert_response :success
  end

  test "should get create" do
    get web_access_keys_create_url
    assert_response :success
  end

  test "should get destroy" do
    get web_access_keys_destroy_url
    assert_response :success
  end

  test "should get toggle" do
    get web_access_keys_toggle_url
    assert_response :success
  end
end
