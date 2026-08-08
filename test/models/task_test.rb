require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires a title" do
    task = projects(:one).tasks.build(title: "")

    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "requires known priority" do
    task = tasks(:one)
    task.priority = "urgent"

    assert_not task.valid?
    assert_includes task.errors[:priority], "is not included in the list"
  end

  test "requires known status" do
    task = tasks(:one)
    task.status = "blocked"

    assert_not task.valid?
    assert_includes task.errors[:status], "is not included in the list"
  end

  test "searches title and description" do
    assert_includes Task.search("homepage"), tasks(:one)
    assert_includes Task.search("report"), tasks(:two)
  end
end
