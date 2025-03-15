require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_password = "V4LidP@ssw0rd"
    @base_user=User.create!({
      email: "leonhard@rosarias-fingers.com",
      password: "R1nGf|n&3r"
    })
    @valid_params = {
      email: "kirk@rosarias-fingers.com",
      password: "|_0ngFing3r"
    }
    @non_permitted_params = {
      armor_set: "thorns"
    }
    @invalid_email = "heysel_yellow_finger"
  end

  # #########
  # # INDEX #
  # #########

  test "#index should return response :ok" do
    get users_url
    assert_response :ok
  end

  test "#index should return an Array as a response" do
    get users_url
    assert_kind_of(Array, JSON.parse(response.body))
  end

  test "#index should return an Array when single User exists" do
    User.destroy_all
    User.create!(@valid_params)
    get users_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty Array when no Users exists" do
    User.destroy_all
    get users_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert body.empty?
  end

  # ########
  # # SHOW #
  # ########

  test "#show should return response :ok with valid user id" do
    get user_url(@base_user.id)
    assert_response :ok
  end

  test "#show returns a User that should match requested user" do
    get user_url(@base_user.id)
    requested_user = JSON.parse(response.body)
    assert_equal @base_user.id, requested_user["id"]
    assert_equal @base_user.email, requested_user["email"]
  end

  test "#show should return response of :not_found when requesting a user that does not exist" do
    get user_url(0)
    assert_response :not_found
  end

  test "#show should return error ActionController::UrlGenerationError know yet with no user id" do
    assert_raises("ActionController::UrlGenerationError") { show user_url }
  end

  # ##########
  # # CREATE #
  # ##########

  test "#create should return response :accepted with valid params" do
    post users_url, params: @valid_params
    assert_response :accepted
  end

  test "#create should create a user with vaild params" do
    post users_url, params: @valid_params
    created_user = JSON.parse(response.body)
    fetched_user = User.find(created_user["id"])
    assert_equal created_user["id"], fetched_user.id
    assert_equal created_user["email"], fetched_user.email
  end

  test "#create should return :bad_request with invalid permitted param" do
    @valid_params[:email] = @invalid_email
    post users_url, params: @valid_params
    assert_response :bad_request
  end

  test "#create should return in response body under email key 'is invalid'" do
    @valid_params[:email] = @invalid_email
    post users_url, params: @valid_params
    body = JSON.parse(response.body)
    assert_response :bad_request
    assert(body["email"].include? "is invalid")
  end

  test "#create does not add non permitted params to returned user" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    post users_url, params: valid_plus_non_permitted_params
    assert_response :accepted
  end

  test "#create should return :accepted with valid permitted params include non permitted params" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    post users_url, params: valid_plus_non_permitted_params
    created_user = JSON.parse(response.body)
    @non_permitted_params.each do |key|
      assert_nil created_user[key]
    end
  end

  # ##########
  # # UPDATE #
  # ##########

  test "#update should return response :ok with valid params" do
    patch user_url(@base_user.id), params: { email: @valid_params[:email] }
    assert_response :ok
  end

  test "#update should update password digest with valid password" do
    previous_digest = @base_user.password_digest
    patch user_url(@base_user.id), params: { password: "K3epH3r$@fe" }
    updated_user = JSON.parse(response.body)
    assert_not_equal previous_digest, updated_user["password_digest"]
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

  test "#update should return response :ok with non permitted params present" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    patch user_url(@base_user.id), params: valid_plus_non_permitted_params
    assert_response :ok
  end

  test "#create should return user not including non permitted params with valid permitted params" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    patch user_url(@base_user.id), params: valid_plus_non_permitted_params
    updated_user = JSON.parse(response.body)
    @non_permitted_params.each do |key|
      assert_nil updated_user[key]
    end
  end

  # ###########
  # # DESTROY #
  # ###########

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

  test "#destroy should return error ActionController::UrlGenerationError know yet with no user id" do
    assert_raises("ActionController::UrlGenerationError") { delete user_url }
  end
end
