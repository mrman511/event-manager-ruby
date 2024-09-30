class AuthController < ApplicationController
  skip_before_action :authorized, only: [ :login ]

  def login
    user = User.find_by!(email: valid_params[:email])
    if user.authenticate(valid_params[:password])
      token = build_jwt(user.id)
      render json: {
        user: user,
        token: token
      }, status: :accepted
    else
      render json: { message: "Incorrect password" }, status: :unauthorized
    end
  end

  private

  def valid_params
    params.permit(:email, :password)
  end
end
