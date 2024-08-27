require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_password = "V4LidP@ssw0rd"
    @base_user=User.create!({
      email: "valid@email.email",
      password: @valid_password
    })
    @valid_params = {
      email: "valid_2@email.email",
      password: @valid_password
    }
    @invalid_params = {
      email: "invalid_email",
      password: @valid_password
    }
  end

  test "#index should return response :ok" do
    get users_url
    assert_response :ok
  end

  test "#index should return an Array as a response" do
    get users_url
    assert_kind_of(Array, JSON.parse(response.body))
  end

  test "#show should return response :ok" do
    get user_url(@base_user.id)
    assert_response :ok
  end

  test "#show should return a Hash as a response" do
    get user_url(@base_user.id)
    assert_kind_of(Hash, JSON.parse(response.body))
  end

  test "#show should return a requested user" do
    get user_url(@base_user.id)
    fetched_user = JSON.parse(response.body)
    assert_equal @base_user.id, fetched_user["id"]
  end

  test "#show should return response of :not_found when requesting a user that does not exist" do
    get user_url(0)
    assert_response :not_found
  end

  test "#create should return response :ok" do
    post users_url, params: @valid_params
    assert_response :ok
  end

  test "#create should create a user with vaild params" do
    post users_url, params: @valid_params
    assert(User.find_by email: @valid_params[:email])
  end

  test "#create should return :unprocessable_entity with invalid params" do
    post users_url, params: @invalid_params
    assert_response :unprocessable_entity
  end

  test "#update should return response :ok with valid params" do
    patch user_url(@base_user.id), params: @valid_params
    assert_response :ok
  end

  test "#update should update user in the database" do
    patch user_url(@base_user.id), params: @valid_params
    updated_user = User.find(@base_user.id)
    assert_equal updated_user.email, @valid_params[:email]
  end

  test "#update should return response :unprocessable_entity with invalid params" do
    patch user_url(@base_user.id), params: @invalid_params
    assert_response :unprocessable_entity
  end

  test "#update should return response :unprocessable_entity with empty params" do
    patch user_url(@base_user.id), params: {}
    assert_response :unprocessable_entity
  end

  test "#destroy should return response :ok with valid user" do
    delete user_url(@base_user.id)
    assert_response :ok
  end

  test "#destroy should destroy the specified user in the database" do
    user_id = @base_user.id
    delete user_url(user_id)
    assert_raises ("ActiveRecord::RecordNotFound") { User.find(user_id) }
  end

  test "#destroy should return response :not_found with invalid user" do
    delete user_url(0)
    assert_response :not_found
  end
end
