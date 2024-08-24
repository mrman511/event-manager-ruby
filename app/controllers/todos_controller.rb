class TodosController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    todos = Todo.all
    render json: todos
  end

  def show
    todo = Todo.find(params[:id])
    render json: todo
  end

  def create
    todo = Todo.create!(valid_params)
    if todo.save
      render json: todo, status: 200
    else
      debugger
      render json: todo.errors, status: :unprocessable_entity
    end
  end
  
  private

  def valid_params
    params.require(:todo).permit(:title, :status, :is_completed)
  end
end
