require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests" do
    get projects_path

    assert_redirected_to new_session_path
  end

  test "lists only current user's projects" do
    sign_in_as users(:one)

    get projects_path

    assert_response :success
    assert_select "td", text: "Website Redesign"
    assert_select "td", text: "Internal Portal", count: 0
  end

  test "filters projects by status" do
    sign_in_as users(:one)

    get projects_path, params: { status: "active" }

    assert_response :success
    assert_select "td", text: "Website Redesign"
  end

  test "shows a project" do
    sign_in_as users(:one)

    get project_path(projects(:one))

    assert_response :success
    assert_select "h1", "Website Redesign"
  end

  test "does not show another user's project" do
    sign_in_as users(:one)

    get project_path(projects(:two))

    assert_response :not_found
  end

  test "creates project for current user's client" do
    sign_in_as users(:one)

    assert_difference "users(:one).projects.count", 1 do
      post projects_path, params: {
        project: {
          client_id: clients(:one).id,
          name: "Brand Refresh",
          description: "Refresh identity system",
          start_date: "2026-08-11",
          deadline: "2026-09-01",
          budget: "1800.00",
          status: "planned"
        }
      }
    end

    assert_redirected_to project_path(Project.order(:created_at).last)
  end

  test "does not create project for another user's client" do
    sign_in_as users(:one)

    assert_no_difference "Project.count" do
      post projects_path, params: {
        project: {
          client_id: clients(:two).id,
          name: "Bad Project",
          status: "planned"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "updates project" do
    sign_in_as users(:one)

    patch project_path(projects(:one)), params: {
      project: {
        client_id: clients(:one).id,
        name: "Updated Website",
        description: projects(:one).description,
        start_date: projects(:one).start_date,
        deadline: projects(:one).deadline,
        budget: projects(:one).budget,
        status: "completed"
      }
    }

    assert_redirected_to project_path(projects(:one))
    assert_equal "Updated Website", projects(:one).reload.name
    assert_equal "completed", projects(:one).status
  end

  test "deletes project" do
    sign_in_as users(:one)

    assert_difference "Project.count", -1 do
      delete project_path(projects(:one))
    end

    assert_redirected_to projects_path
  end
end
