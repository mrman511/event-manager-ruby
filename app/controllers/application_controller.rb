class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :authorized

  def build_jwt(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + (7*24*60*60)
    }
    JWT.encode(payload, ENV["SECRET_KEY"] || "test key")
  end

  def decoded_jwt
    header = request.headers["Authorization"]
    if header
      token = header.split(" ")[1]
      begin
        JWT.decode(token, ENV["SECRET_KEY"] || "test key")
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def check_authorized_for(user_id)
    if decoded_jwt
      if user_id.to_i == decoded_jwt[0]["user_id"]
        if decoded_jwt[0]["exp"] >= Time.now.to_i
          return true
        end
      end
    end
    false
  end

  def current_user
    if decoded_jwt
      user_id = decoded_jwt[0]["user_id"]
      @user = User.find_by(id: user_id)
    end
  end

  def authorized
    unless !!current_user
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end
end
