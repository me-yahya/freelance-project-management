class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @query = params[:query].to_s.strip
    @clients = current_user.clients.search(@query).order(:name)
  end

  def show
  end

  def new
    @client = current_user.clients.build
  end

  def create
    @client = current_user.clients.build(client_params)

    if @client.save
      redirect_to @client, notice: "Client created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, status: :see_other, notice: "Client deleted."
  end

  private
    def set_client
      @client = current_user.clients.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:name, :company, :email, :phone, :address, :notes)
    end
end
