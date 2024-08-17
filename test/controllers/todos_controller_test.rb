require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  test "Retrieves Index page" do
    get '/api/v1/todos'
    assert_response :success
    assert_not_nil assigns(:todos)
  end
end
