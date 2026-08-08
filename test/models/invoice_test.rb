require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  test "requires invoice number" do
    invoice = projects(:one).invoices.build(invoice_number: "", amount: 100)

    assert_not invoice.valid?
    assert_includes invoice.errors[:invoice_number], "can't be blank"
  end

  test "requires positive amount" do
    invoice = invoices(:one)
    invoice.amount = 0

    assert_not invoice.valid?
    assert_includes invoice.errors[:amount], "must be greater than 0"
  end

  test "requires known status" do
    invoice = invoices(:one)
    invoice.status = "lost"

    assert_not invoice.valid?
    assert_includes invoice.errors[:status], "is not included in the list"
  end

  test "rejects due date before issue date" do
    invoice = invoices(:one)
    invoice.issue_date = Date.new(2026, 8, 10)
    invoice.due_date = Date.new(2026, 8, 9)

    assert_not invoice.valid?
    assert_includes invoice.errors[:due_date], "must be after the issue date"
  end

  test "searches invoice number" do
    assert_includes Invoice.search("INV-001"), invoices(:one)
  end
end
