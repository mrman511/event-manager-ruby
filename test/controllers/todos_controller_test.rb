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


  test "#index should return an Array when single Todo exists" do
    Todo.destroy_all
    Todo.create!(@valid_params)
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty Array when no Todos exists" do
    Todo.destroy_all
    get todos_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert body.empty?
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

  test "#create should return :accepted with valid_params" do
  post todos_url, params: { todo: @valid_params }
  assert_response :accepted
  end

  test "#create returns key 'title' with array that includes 'can't be blank' with missing title" do
    @valid_params.delete(:title)
    post todos_url, params: { todo: @valid_params }
    body = JSON.parse(response.body)
    assert(body["title"].include? "can't be blank")
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
end
