require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create stores a permanent browser cookie" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    set_cookie = response.headers["Set-Cookie"].to_s
    assert_includes set_cookie, "session_id="
    assert_match(/expires=/i, set_cookie)
    assert_match(/httponly/i, set_cookie)
    assert_match(/samesite=lax/i, set_cookie)
  end

  test "session cookie keeps user authenticated on later requests" do
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert cookies[:session_id]

    get root_path

    assert_response :success
    assert_select "h1", /Welcome/
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
