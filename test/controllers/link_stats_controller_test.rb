require "test_helper"

class LinkStatsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get link_stats_show_url
    assert_response :success
  end
end
