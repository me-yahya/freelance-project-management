require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "requires a name" do
    client = users(:one).clients.build(name: "")

    assert_not client.valid?
    assert_includes client.errors[:name], "can't be blank"
  end

  test "allows blank email" do
    client = users(:one).clients.build(name: "No Email", email: "")

    assert client.valid?
  end

  test "rejects invalid email" do
    client = users(:one).clients.build(name: "Bad Email", email: "bad-email")

    assert_not client.valid?
    assert_includes client.errors[:email], "is invalid"
  end

  test "normalizes email" do
    client = users(:one).clients.create!(name: "Mixed Email", email: "  Mixed@Example.COM ")

    assert_equal "mixed@example.com", client.email
  end

  test "searches name company and email" do
    assert_includes Client.search("acme"), clients(:one)
    assert_includes Client.search("beta"), clients(:two)
    assert_includes Client.search("hello@acme"), clients(:one)
  end
end
