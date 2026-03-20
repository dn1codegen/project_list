require "test_helper"

class Api::ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_projects_create_url
    assert_response :success
  end
end
