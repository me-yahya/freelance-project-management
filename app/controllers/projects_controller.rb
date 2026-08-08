class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :set_clients, only: %i[ new create edit update ]

  def index
    @query = params[:query].to_s.strip
    @status = params[:status].to_s
    @projects = current_user.projects
      .includes(:client)
      .search(@query)
      .with_status(@status)
      .order(deadline: :asc, name: :asc)
  end

  def show
    @tasks = @project.tasks.order(due_date: :asc, title: :asc)
    @invoices = @project.invoices.order(due_date: :asc, invoice_number: :asc)
  end

  def new
    @project = Project.new(status: "planned")
  end

  def create
    attributes = project_params
    client = current_user.clients.find(attributes.delete(:client_id))
    @project = client.projects.build(attributes)

    if @project.save
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @project = Project.new(project_params.except(:client_id))
    @project.errors.add(:client, "must belong to your account")
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    attributes = project_params
    client = current_user.clients.find(attributes.delete(:client_id))

    if @project.update(attributes.merge(client: client))
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @project.errors.add(:client, "must belong to your account")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @project.destroy
    redirect_to projects_path, status: :see_other, notice: "Project deleted."
  end

  private
    def set_project
      @project = current_user.projects.find(params[:id])
    end

    def set_clients
      @clients = current_user.clients.order(:name)
    end

    def project_params
      params.require(:project).permit(:name, :description, :client_id, :start_date, :deadline, :budget, :status, files: [])
    end
end
