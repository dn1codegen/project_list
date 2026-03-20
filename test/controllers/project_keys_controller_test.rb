require "test_helper"

class ProjectKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get project_keys_index_url
    assert_response :success
  end

  test "should get create" do
    get project_keys_create_url
    assert_response :success
  end

  test "should get destroy" do
    get project_keys_destroy_url
    assert_response :success
  end

  test "should get toggle" do
    get project_keys_toggle_url
    assert_response :success
  end
end
