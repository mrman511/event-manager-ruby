require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_params={
      title: "Valid Title",
      status: "created",
      is_completed: false
    }
    @invalid_title="title for invalid",
    @non_permitted_params={ valid_param: false }
    @todo = Todo.create!(@valid_params)
    @updated_params = {
      title: "updated Title",
      status: "Awaiting Approval",
      is_completed: true
    }
  end

  test "#index should return response :ok" do
    get todos_url
    assert_response :ok
  end

  test "#index should return an Array when multiple Todos exist" do
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert(Todo.count > 1)
  end

  test "#index should return an Array when single Todo exists" do
    Todo.destroy_all
    Todo.create!(@valid_params)
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert(Todo.count == 1)
  end

  test "#index should return an empty Array when no Todos exists" do
    Todo.destroy_all
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert(Todo.count == 0)
  end

  test "#index should return an array where all items can be retrieved from Todo Model" do
    get todos_url
    body = JSON.parse(response.body)
    body.each do |todo|
      fetched_todo = Todo.find(todo["id"])
      assert_equal todo["title"], fetched_todo["title"]
      assert_equal todo["status"], fetched_todo["status"]
      assert_equal todo["is_completed"], fetched_todo["is_completed"]
    end
  end

  test "#show should respond with :ok when fetched with valid Todo id" do
    get todo_url(@todo)
    assert_response :ok
  end

  test "#show fetched Todo should match created Todo" do
    get todo_url(@todo)
    fetched_todo = JSON.parse(response.body)

    assert_equal @todo.title, fetched_todo["title"]
    assert_equal @todo.status, fetched_todo["status"]
    assert_equal @todo.is_completed, fetched_todo["is_completed"]
  end

  test "#create should return :accepted with valid_params" do
    post todos_url, params: { todo: @valid_params }
    assert_response :accepted
  end

  test "#create should return :bad_request with invalid permitted param" do
    @valid_params["title"] = @invalid_title
    post todos_url, params: { todo: @valid_params }
    assert_response :bad_request
  end

  test "#create should create todo with valid params" do
    assert_difference("Todo.count") do
      post todos_url, params: { todo: @valid_params }
    end
  end

  test "#create should responed with Todo that can be fetched from the database" do
    post todos_url, params: { todo: @valid_params }
    created_todo = JSON.parse(response.body)
    fetched_todo = Todo.find(created_todo["id"])
    assert_equal @valid_params[:title], fetched_todo.title
    assert_equal @valid_params[:status], fetched_todo.status
    assert_equal @valid_params[:is_completed], fetched_todo.is_completed
  end

  test "#create should return response :accepted non permitted params present" do
    params_with_non_permitted = @valid_params.merge(@non_permitted_params)
    post todos_url, params: { todo: params_with_non_permitted }
    assert_response :accepted
  end

  test "#create does not add non permitted params to created Todo" do
    params_with_non_permitted = @valid_params.merge(@non_permitted_params)
    post todos_url, params: { todo: params_with_non_permitted }
    created_todo = JSON.parse(response.body)
    @non_permitted_params.each do |key|
      assert_nil created_todo[key]
    end
  end

  test "#create returns key 'title' with array that includes 'can't be blank' with missing title" do
    @valid_params.delete(:title)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["title"].include? "can't be blank")
  end

  test "#create returns key 'status' with array that includes 'can't be blank' with missing title" do
    @valid_params.delete(:status)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["status"].include? "can't be blank")
  end

  test "#create returns key 'is_completed' with array that includes 'is not included in the list' with missing title" do
    @valid_params.delete(:is_completed)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["is_completed"].include? "is not included in the list")
  end


  test "#create returns key 'status' with array that includes 'can't be blank' with missing status" do
    @valid_params.delete(:status)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["status"].include? "can't be blank")
  end

  test "#create returns key 'is_completed' with array that includes 'is not included in the list' with missing status" do
    @valid_params.delete(:is_completed)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["is_completed"].include? "is not included in the list")
  end

  test "#update should have response of :ok when given valid params" do
    patch todo_url(@todo), params: { todo: @updated_params }
    assert_response :accepted
  end

  test "#update should return response :accepted non permitted params present" do
    params_with_non_permitted = @valid_params.merge(@non_permitted_params)
    patch todo_url(@todo), params: { todo: params_with_non_permitted }
    assert_response :accepted
  end

  test "#update should update the todo in the database" do
    patch todo_url(@todo), params: { todo: @updated_params }
    fetched_todo = Todo.find(@todo.id)

    assert_equal @updated_params[:title], fetched_todo.title
    assert_equal @updated_params[:status], fetched_todo.status
    assert_equal @updated_params[:is_completed], fetched_todo.is_completed
  end

  test "#update does not add non permitted params to updated Todo" do
    params_with_non_permitted = @valid_params.merge(@non_permitted_params)
    patch todo_url(@todo), params: { todo: params_with_non_permitted }
    fetched_todo = Todo.find(@todo.id)

    @non_permitted_params.each do |key|
      assert_nil fetched_todo[key]
    end
  end

  test "#update should return response :not_found with invalid todo" do
    patch todo_url({ "id": 0 }), params: { todo: @updated_params }
    assert_response :not_found
  end

  test "#update should return response of :bad_request with no params" do
    patch todo_url(@todo), params: {}
    assert_response :bad_request
  end

  test "#update should return error ActionController::UrlGenerationError with no todo id" do
    assert_raises("ActionController::UrlGenerationError") { patch todo_url }
  end

  test "#destroy should return response of :ok when valid todo is given" do
    delete todo_url(@todo)
    assert_response :ok
  end

  test "#destroy deletes the requested item form the database" do
    id = @todo.id
    delete todo_url(@todo)
    assert_raises("ActiveRecord::RecordNotFound") { Todo.find(id) }
  end

  test "#destroy should return response :not_found when invalid Todo is given" do
    delete todo_url({ "id": 0 })
    assert_response :not_found
  end

  test "#destroy should return error ActionController::UrlGenerationError know yet with no todo id" do
    assert_raises("ActionController::UrlGenerationError") { delete todo_url }
  end
end
