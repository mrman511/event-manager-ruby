class UsersController < ApplicationController
  # protect_from_forgery with: :null_session
  # before_action :authorized
  skip_before_action :authorized

  def index
    users = User.all
    render json: users
  end

  def show
    user = User.find(params[:id])
    if user
      render json: user
      return
    end
    render json: user.errors, status: :not_found
  end

  def create
    user = User.create(permitted_params)
    if user.save
      render json: user, status: :accepted
    else
      render json: user.errors, status: :bad_request
    end
  end

  def update
    user = User.find(params[:id])
    if user and !permitted_params.empty?
      if permitted_params[:email]
        user.update_attribute(:email, permitted_params[:email])
      end
      if permitted_params[:password]
        user.update_attribute(:password, permitted_params[:password])
      end
      render json: user, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    if user
      user.destroy
      render json: { message: "User Destroyed" }, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:email, :password)
  end
end
