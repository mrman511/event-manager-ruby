class HostsController < ApplicationController
  def index
    render json: Host.all
  end

  def show
    render json: Host.find(params[:id])
  end

  def create
    if !formatted_params
      render status: :bad_request
    else
      host = Host.new(formatted_params)
      host.save(validate: false)
      render json: host, status: :accepted
    end
  end

  def update
    host = Host.find(params[:id])
    if host
      if has_update(host)
        host.update!(update_params)
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
      host.users = []
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
    params.permit(:name, :user_id)
  end

  def update_params
    params.permit(:name)
  end

  def formatted_params
    if !permitted_params[:name] || !permitted_params[:name]
      return nil
    end
    host_user = User.find(permitted_params[:user_id])
    { name: permitted_params[:name], users: [ host_user ] }
  end
end
