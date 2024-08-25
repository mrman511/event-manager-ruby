class UsersController < ApplicationController
  # protect_from_forgery with: :null_session
  before_action :authorized, only: [ :show, :update ]
  # skip_before_action :authorized, only: [:create]

  def index
    users = User.all
    render json: users
  end

  def show
    decoded_token = decoded_jwt
    user = User.find(params[:id])
    if !user
      render json: user.errors, status: :not_found
      return
    end
    if check_authorized_for(user.id)
      render json: user
    else
      render json: user.errors, status: :unauthorized
    end
  end

  def create
    user = User.create(permitted_params)
    token = build_jwt(user.id)
    if user.save
      render json: { user: user, token: token }, status: :accepted
    else
      render json: user.errors, status: :bad_request
    end
  end

  def update
    user = User.find(params[:id])
    if !user
      render json: user.errors, status: :not_found
      return
    end
    if !check_authorized_for(user.id)
      render json: { message: "You are not authorized to view this Content" }, status: :unauthorized
      return
    else
      if !permitted_params.empty?
        if permitted_params[:email]
          user.update_attribute(:email, permitted_params[:email])
        end
        if permitted_params[:password]
          user.update_attribute(:password, permitted_params[:password])
        end
        render json: user, status: :ok
        return
      end
    end
    render json: user.errors, status: :unprocessable_entity
  end

  def destroy
    user = User.find(params[:id])
    if user
      if check_authorized_for(user.id)
        user.destroy
        render json: { message: "User Destroyed" }, status: :ok
      else
        render json: { message: "Unauthorized to delete user" }, status: :unauthorized
      end
    else
      render json: user.errors, status: :not_found
    end
  end

  private

  def permitted_params
    params.permit(:email, :password)
  end
end
