class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy ]
  before_action :set_projects, only: %i[ new create edit update ]

  def index
    @query = params[:query].to_s.strip
    @status = params[:status].to_s
    @invoices = current_user.invoices
      .includes(project: :client)
      .search(@query)
      .with_status(@status)
      .order(due_date: :asc, invoice_number: :asc)
    @total_invoiced = current_user.invoices.sum(:amount)
    @total_paid = current_user.invoices.where(status: "paid").sum(:amount)
  end

  def show
  end

  def new
    @invoice = Invoice.new(status: "draft", issue_date: Date.current, project_id: params[:project_id])
  end

  def create
    attributes = invoice_params
    project = current_user.projects.find(attributes.delete(:project_id))
    @invoice = project.invoices.build(attributes)

    if @invoice.save
      redirect_to @invoice, notice: "Invoice created."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @invoice = Invoice.new(invoice_params.except(:project_id))
    @invoice.errors.add(:project, "must belong to your account")
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    attributes = invoice_params
    project = current_user.projects.find(attributes.delete(:project_id))

    if @invoice.update(attributes.merge(project: project))
      redirect_to @invoice, notice: "Invoice updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    @invoice.errors.add(:project, "must belong to your account")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, status: :see_other, notice: "Invoice deleted."
  end

  private
    def set_invoice
      @invoice = current_user.invoices.find(params[:id])
    end

    def set_projects
      @projects = current_user.projects.includes(:client).order(:name)
    end

    def invoice_params
      params.require(:invoice).permit(:project_id, :invoice_number, :amount, :issue_date, :due_date, :status)
    end
end
