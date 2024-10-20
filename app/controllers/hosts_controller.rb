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

  def update
    host = Host.find(params[:id])
    if host
      if has_update(host)
        host.update!(permitted_params)
        render json: host, status: :accepted
      else
        render json: host, status: :not_modified
      end
    else
      render json: host.errors, status: :not_found
    end
  end

  def destroy
    host = Host.find(params[:id])
    if host
      host.destroy
      render json: { message: "host destroyed" }, status: :ok
    else
      render json: host.errors, status: :unprocessable_entity
    end
  end

  private

  def has_update(host)
    if !permitted_params.empty?
      permitted_params.each do |key, value|
        if value != host[key]
          return true
        end
      end
    end
    false
  end

  def permitted_params
    params.permit(:name)
  end
end
