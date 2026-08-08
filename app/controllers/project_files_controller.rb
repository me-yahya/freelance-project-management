class ProjectFilesController < ApplicationController
  def destroy
    attachment = ActiveStorage::Attachment.find(params[:id])
    raise ActiveRecord::RecordNotFound unless attachment.record_type == "Project"

    project = current_user.projects.find(attachment.record_id)
    attachment.purge

    redirect_to project, status: :see_other, notice: "File removed."
  end
end
