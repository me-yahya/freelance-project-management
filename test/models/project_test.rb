require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires a name" do
    project = clients(:one).projects.build(name: "")

    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "requires a known status" do
    project = projects(:one)
    project.status = "unknown"

    assert_not project.valid?
    assert_includes project.errors[:status], "is not included in the list"
  end

  test "rejects negative budget" do
    project = projects(:one)
    project.budget = -1

    assert_not project.valid?
    assert_includes project.errors[:budget], "must be greater than or equal to 0"
  end

  test "rejects deadline before start date" do
    project = projects(:one)
    project.start_date = Date.new(2026, 8, 10)
    project.deadline = Date.new(2026, 8, 9)

    assert_not project.valid?
    assert_includes project.errors[:deadline], "must be after the start date"
  end

  test "searches name and description" do
    assert_includes Project.search("website"), projects(:one)
    assert_includes Project.search("dashboard"), projects(:two)
  end

  test "can attach files" do
    projects(:one).files.attach(
      io: StringIO.new("requirements"),
      filename: "requirements.txt",
      content_type: "text/plain"
    )

    assert projects(:one).files.attached?
  end
end
