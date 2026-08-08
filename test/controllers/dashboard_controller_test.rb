require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows dashboard to authenticated users" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
    assert_select "h1", /Welcome/
    assert_select "span", "Total clients"
    assert_select "h2", "Recent projects"
    assert_select "h2", "Upcoming deadlines"
  end
end
