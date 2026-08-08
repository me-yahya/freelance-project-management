require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests" do
    get invoices_path

    assert_redirected_to new_session_path
  end

  test "lists only current user's invoices" do
    sign_in_as users(:one)

    get invoices_path

    assert_response :success
    assert_select "td", text: "INV-001"
    assert_select "td", text: "INV-002", count: 0
  end

  test "shows invoice" do
    sign_in_as users(:one)

    get invoice_path(invoices(:one))

    assert_response :success
    assert_select "h1", "INV-001"
  end

  test "does not show another user's invoice" do
    sign_in_as users(:one)

    get invoice_path(invoices(:two))

    assert_response :not_found
  end

  test "creates invoice for current user's project" do
    sign_in_as users(:one)

    assert_difference "users(:one).invoices.count", 1 do
      post invoices_path, params: {
        invoice: {
          project_id: projects(:one).id,
          invoice_number: "INV-NEW",
          amount: "900.00",
          issue_date: "2026-08-12",
          due_date: "2026-08-29",
          status: "draft"
        }
      }
    end

    assert_redirected_to invoice_path(Invoice.order(:created_at).last)
  end

  test "does not create invoice for another user's project" do
    sign_in_as users(:one)

    assert_no_difference "Invoice.count" do
      post invoices_path, params: {
        invoice: {
          project_id: projects(:two).id,
          invoice_number: "INV-BAD",
          amount: "900.00",
          status: "draft"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "does not create invalid invoice" do
    sign_in_as users(:one)

    assert_no_difference "Invoice.count" do
      post invoices_path, params: {
        invoice: {
          project_id: projects(:one).id,
          invoice_number: "",
          amount: "0",
          status: "draft"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "updates invoice" do
    sign_in_as users(:one)

    patch invoice_path(invoices(:one)), params: {
      invoice: {
        project_id: projects(:one).id,
        invoice_number: "INV-UPDATED",
        amount: invoices(:one).amount,
        issue_date: invoices(:one).issue_date,
        due_date: invoices(:one).due_date,
        status: "paid"
      }
    }

    assert_redirected_to invoice_path(invoices(:one))
    assert_equal "INV-UPDATED", invoices(:one).reload.invoice_number
    assert_equal "paid", invoices(:one).status
  end

  test "deletes invoice" do
    sign_in_as users(:one)

    assert_difference "Invoice.count", -1 do
      delete invoice_path(invoices(:one))
    end

    assert_redirected_to invoices_path
  end
end
