class UsersController < ApplicationController
  protect_from_forgery with: :null_session

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
    user = User.create(valid_params)
    if user.save
      render json: user, status: 200
      return
    end
    render json: user.errors, status: :unprocessable_entity
  end

  def update
    user = User.find(params[:id])
    if user and !valid_params.empty?
      user.update!(valid_params)
      render json: { message: "User updated" }, status: :ok
      return
    end
    render json: user.errors, status: :unprocessable_entity
  end

  def destroy
    user = User.find(params[:id])
    if user
      user.destroy
      render json: { message: "User Destroyed" }, status: :ok
      return
    end
    render json: user.errors, status: :unprocessable_entity
  end

  private

  def valid_params
    params.permit(:email, :password)
  end
end
