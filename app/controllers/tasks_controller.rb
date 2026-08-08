class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy complete ]
  before_action :set_projects, only: %i[ new create edit update ]

  def index
    @query = params[:query].to_s.strip
    @status = params[:status].to_s
    @priority = params[:priority].to_s
    @tasks = current_user.tasks
      .includes(project: :client)
      .search(@query)
      .with_status(@status)
      .with_priority(@priority)
      .order(due_date: :asc, title: :asc)
  end

  def show
  end

  def new
    @task = Task.new(status: "to_do", priority: "medium", project_id: params[:project_id])
  end

  def create
    attributes = task_params
    project = current_user.projects.find(attributes.delete(:project_id))
    @task = project.tasks.build(attributes)

    if @task.save
      redirect_to @task, notice: "Task created."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @task = Task.new(task_params.except(:project_id))
    @task.errors.add(:project, "must belong to your account")
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    attributes = task_params
    project = current_user.projects.find(attributes.delete(:project_id))

    if @task.update(attributes.merge(project: project))
      redirect_to @task, notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @task.errors.add(:project, "must belong to your account")
    render :edit, status: :unprocessable_entity
  end

  def complete
    @task.update!(status: "completed")
    redirect_back fallback_location: tasks_path, notice: "Task marked completed."
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, status: :see_other, notice: "Task deleted."
  end

  private
    def set_task
      @task = current_user.tasks.find(params[:id])
    end

    def set_projects
      @projects = current_user.projects.includes(:client).order(:name)
    end

    def task_params
      params.require(:task).permit(:project_id, :title, :description, :due_date, :priority, :status)
    end
end
