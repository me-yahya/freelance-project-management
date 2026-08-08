require "test_helper"

class ProjectFilesControllerTest < ActionDispatch::IntegrationTest
  test "deletes current user's project file" do
    sign_in_as users(:one)
    project = projects(:one)
    project.files.attach(io: StringIO.new("requirements"), filename: "requirements.txt", content_type: "text/plain")
    attachment = project.files.attachments.last

    assert_difference "project.files.attachments.count", -1 do
      delete project_file_path(attachment)
    end

    assert_redirected_to project_path(project)
  end

  test "does not delete another user's project file" do
    sign_in_as users(:one)
    project = projects(:two)
    project.files.attach(io: StringIO.new("private"), filename: "private.txt", content_type: "text/plain")
    attachment = project.files.attachments.last

    delete project_file_path(attachment)

    assert_response :not_found
  end
end
