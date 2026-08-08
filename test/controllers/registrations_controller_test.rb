require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new registration form is public" do
    get new_registration_path

    assert_response :success
  end

  test "creates account and starts a session" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          name: "New Freelancer",
          email_address: "new@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "does not create invalid account" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          name: "",
          email_address: "not-an-email",
          password: "password",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "edit profile requires authentication" do
    get edit_registration_path

    assert_redirected_to new_session_path
  end

  test "updates profile without changing password" do
    user = users(:one)
    sign_in_as user

    patch registration_path, params: {
      user: {
        name: "Updated Name",
        email_address: "updated@example.com",
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to edit_registration_path
    assert_equal "Updated Name", user.reload.name
    assert user.authenticate("password")
  end

  test "updates password" do
    user = users(:one)
    sign_in_as user

    patch registration_path, params: {
      user: {
        name: user.name,
        email_address: user.email_address,
        password: "new-password",
        password_confirmation: "new-password"
      }
    }

    assert_redirected_to edit_registration_path
    assert user.reload.authenticate("new-password")
  end
end
