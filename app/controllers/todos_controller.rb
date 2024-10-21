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

  def update
    todo = Todo.find(params[:id])
    if todo and !permitted_params.empty?
      todo.update!(permitted_params)
      render json: todo, status: :accepted
    else
      render json: todo.errors, status: :unprocessable_entity
    end
  end

  def destroy
    todo = Todo.find(params[:id])
    todo.destroy
    render json: { message: "Todo destroyed" }, status: :ok
  end

  private

  def permitted_params
    params.require(:todo).permit(:title, :status, :is_completed)
  end
end
