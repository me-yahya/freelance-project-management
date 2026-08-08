require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests" do
    get tasks_path

    assert_redirected_to new_session_path
  end

  test "lists only current user's tasks" do
    sign_in_as users(:one)

    get tasks_path

    assert_response :success
    assert_select "td", text: "Draft homepage"
    assert_select "td", text: "Configure reports", count: 0
  end

  test "shows task" do
    sign_in_as users(:one)

    get task_path(tasks(:one))

    assert_response :success
    assert_select "h1", "Draft homepage"
  end

  test "does not show another user's task" do
    sign_in_as users(:one)

    get task_path(tasks(:two))

    assert_response :not_found
  end

  test "creates task for current user's project" do
    sign_in_as users(:one)

    assert_difference "users(:one).tasks.count", 1 do
      post tasks_path, params: {
        task: {
          project_id: projects(:one).id,
          title: "Review copy",
          description: "Review page content",
          due_date: "2026-08-22",
          priority: "medium",
          status: "to_do"
        }
      }
    end

    assert_redirected_to task_path(Task.order(:created_at).last)
  end

  test "does not create task for another user's project" do
    sign_in_as users(:one)

    assert_no_difference "Task.count" do
      post tasks_path, params: {
        task: {
          project_id: projects(:two).id,
          title: "Bad Task",
          priority: "medium",
          status: "to_do"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "updates task" do
    sign_in_as users(:one)

    patch task_path(tasks(:one)), params: {
      task: {
        project_id: projects(:one).id,
        title: "Updated task",
        description: tasks(:one).description,
        due_date: tasks(:one).due_date,
        priority: "low",
        status: "to_do"
      }
    }

    assert_redirected_to task_path(tasks(:one))
    assert_equal "Updated task", tasks(:one).reload.title
  end

  test "marks task completed" do
    sign_in_as users(:one)

    patch complete_task_path(tasks(:one))

    assert_redirected_to tasks_path
    assert_equal "completed", tasks(:one).reload.status
  end

  test "deletes task" do
    sign_in_as users(:one)

    assert_difference "Task.count", -1 do
      delete task_path(tasks(:one))
    end

    assert_redirected_to tasks_path
  end
end
