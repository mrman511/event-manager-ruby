require "rails_helper"

RSpec.describe "V1 ToDo API", type: :request do
  describe 'GET /api/v1/todos' do
    it "Retrieves a list of Todo items" do
      headers = { 'ACCEPT' => 'application/json' }
      get "/api/v1/todos", headers: headers
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to be_kind_of(Array)
    end
  end
  
  describe "GET /api/v1/todos/:id" do
    let!(:todo) do
      Todo.create!(title: 'Delete Test', status: "testing", is_completed: false)
    end
    
    it "Retrieves requested todo item" do
      get "/api/v1/todos/#{todo.id}"
      response_json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response_json).to be_kind_of(Hash)
      expect(response_json['id']).to eq(todo.id)
    end
  end

  describe '#post' do
    it "Creates new todo item" do
      headers = { 'ACCEPT' => 'application/json' }
      new_todo = {title: "Test Title", status: 'just a test', is_completed: false}
      post "/api/v1/todos", params: {:todo => new_todo}, headers: headers
      response_json = JSON.parse(response.body)
      expect(response.status).to eq(201)
      expect(response_json).to be_kind_of(Hash)
      new_todo.each { |key, value|  expect(value).to eq(response_json["#{key}"])}
      expect(response_json).to include("id")
    end
  end
  
  describe 'PATCH /api/v1/todos/:id' do
    let!(:todo) do
      Todo.create!(title: 'Update Test', status: "testing", is_completed: false)
    end
    let!(:params) do 
      {todo: {is_completed: true}}
    end
    
    it "Updates a Todo Item" do
      patch "/api/v1/todos/#{todo.id}", params: params
      todo.reload
      response_json = JSON.parse(response.body)
      expect(todo.is_completed).to eq(true)
      expect(response.status).to eq(200)
      expect(response_json["message"]).to eq('Todo updated')
    end
  end
  
  describe "DESTROY /api/v1/todos/:id" do
    let!(:todo) do
      Todo.create!(title: 'Delete Test', status: "testing", is_completed: false)
    end
    
    it "Returns confirmation of Todo Item deleted todo item" do
      delete "/api/v1/todos/#{todo.id}"
      response_json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response_json['message']).to eq('Todo destroyed')
    end
  end 
end