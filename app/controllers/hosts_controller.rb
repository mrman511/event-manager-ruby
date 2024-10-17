class HostsController < ApplicationController
  def index
    render json: Host.all
  end

  def show
    render json: Host.find(params[:id])
  end

  def create
    host = Host.new(permitted_params)
    if host.valid?
      host.save()
      render json: host, status: :accepted
    else
      render json: host.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:name)
  end
end
