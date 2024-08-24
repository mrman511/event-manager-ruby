require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  @created_todo
  setup do
    @valid_params={
      title: "Valid Title",
      status: "created",
      is_completed: false
    }
    @invalid_params={
      title: "title for invalid",
      is_completed: false
    }
    @todo = Todo.create!(@valid_params)
  end

  test "#index should return response :ok" do
    get todos_url
    assert_response :ok
  end

  test "#index should return an Array" do
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
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

  test "#create should create todo with valid params" do
    assert_difference("Todo.count") do
      post todos_url, params: { todo: @valid_params }
    end
  end

  test "#create should return a Hash" do
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert_kind_of(Hash, body)
  end

  test "#create should responed with Todo that can be fetched from the database" do
    post todos_url, params: { todo: @valid_params }
    created_todo = JSON.parse(response.body)
    fetched_todo = Todo.find(created_todo["id"])

    assert_equal @valid_params[:title], fetched_todo.title
    assert_equal @valid_params[:status], fetched_todo.status
    assert_equal @valid_params[:is_completed], fetched_todo.is_completed
  end

  test "#create returns status :unprocessable_entity when given invalid params" do
    post todos_url, params: { todo: @invalid_params }
    assert_response :unprocessable_entity
  end
end
