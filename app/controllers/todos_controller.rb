class TodosController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    render json: Todo.all
  end

  def show
    render json: Todo.find(params[:id])
  end

  def create
    todo = Todo.create(permitted_params)
    if todo.valid?
      render json: todo, status: :accepted
    else
      render json: todo.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:todo).permit(:title, :status, :is_completed)
  end
end
