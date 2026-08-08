require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests" do
    get clients_path

    assert_redirected_to new_session_path
  end

  test "lists only current user's clients" do
    sign_in_as users(:one)

    get clients_path

    assert_response :success
    assert_select "td", text: "Acme Design"
    assert_select "td", text: "Beta Systems", count: 0
  end

  test "searches current user's clients" do
    sign_in_as users(:one)

    get clients_path, params: { query: "acme" }

    assert_response :success
    assert_select "td", text: "Acme Design"
  end

  test "shows a client" do
    sign_in_as users(:one)

    get client_path(clients(:one))

    assert_response :success
    assert_select "h1", "Acme Design"
  end

  test "does not show another user's client" do
    sign_in_as users(:one)

    get client_path(clients(:two))

    assert_response :not_found
  end

  test "creates client for current user" do
    sign_in_as users(:one)

    assert_difference "users(:one).clients.count", 1 do
      post clients_path, params: {
        client: {
          name: "New Client",
          company: "New Co",
          email: "new@example.com",
          phone: "555-0300",
          address: "789 Center Street",
          notes: "New lead"
        }
      }
    end

    assert_redirected_to client_path(Client.order(:created_at).last)
  end

  test "does not create invalid client" do
    sign_in_as users(:one)

    assert_no_difference "Client.count" do
      post clients_path, params: { client: { name: "", email: "bad" } }
    end

    assert_response :unprocessable_entity
  end

  test "updates client" do
    sign_in_as users(:one)

    patch client_path(clients(:one)), params: {
      client: {
        name: "Updated Client",
        company: clients(:one).company,
        email: clients(:one).email,
        phone: clients(:one).phone,
        address: clients(:one).address,
        notes: clients(:one).notes
      }
    }

    assert_redirected_to client_path(clients(:one))
    assert_equal "Updated Client", clients(:one).reload.name
  end

  test "deletes client" do
    sign_in_as users(:one)

    assert_difference "Client.count", -1 do
      delete client_path(clients(:one))
    end

    assert_redirected_to clients_path
  end
end
