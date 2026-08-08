class DashboardController < ApplicationController
  def index
    @client_count = current_user.clients.count
    @active_project_count = current_user.projects.where(status: "active").count
    @completed_project_count = current_user.projects.where(status: "completed").count
    @pending_task_count = current_user.tasks.where.not(status: "completed").count
    @overdue_task_count = current_user.tasks.overdue.count
    @total_invoiced = current_user.invoices.sum(:amount)
    @total_paid = current_user.invoices.where(status: "paid").sum(:amount)
    @outstanding_amount = @total_invoiced - @total_paid
    @collection_rate = @total_invoiced.positive? ? ((@total_paid / @total_invoiced) * 100).round : 0
    @recent_projects = current_user.projects.includes(:client).order(updated_at: :desc).limit(5)
    @upcoming_deadlines = current_user.projects
      .includes(:client)
      .where.not(deadline: nil)
      .where("deadline >= ?", Date.current)
      .order(:deadline)
      .limit(5)
    @priority_tasks = current_user.tasks
      .includes(project: :client)
      .where.not(status: "completed")
      .order(due_date: :asc, priority: :desc)
      .limit(5)
    @recent_invoices = current_user.invoices
      .includes(project: :client)
      .order(updated_at: :desc)
      .limit(5)
  end
end
