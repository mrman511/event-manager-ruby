require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_params = {
      email: "valid@email.email",
      password: "V@l1dPa$5"
    }
    @user = User.create!(@valid_params)
  end

  test "#login returns response :accepted with valid params" do
    post "/login", params: @valid_params
    assert_response :accepted
  end

  test "#login returns a Hash with keys user and token" do
    post "/login", params: @valid_params
    body = JSON.parse(response.body)
    assert_kind_of(Hash, body)
    assert(body["user"])
    assert(body["token"])
  end

  test "#login return response :unauthorized with incorrect password" do
    post "/login", params: { email: @valid_params[:email], password: "1nV@lidP@5s" }
    assert_response :unauthorized
  end

  test "#login return response :not_found with incorrect email" do
    post "/login", params: { email: "invalid@email.email", password: @valid_params[:password] }
    assert_response :not_found
  end
end
