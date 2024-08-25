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
    if todo and !valid_params.empty?
      todo.update!(valid_params)
      render json: { message: "Todo updated" }, status: :ok
      return
    end
    render json: { error: "unable to update Todo" }, status: 500
  end

  def destroy
    todo = Todo.find(params[:id])
    if todo
      todo.destroy
      render json: { message: "Todo destroyed" }, status: :ok
      return
    end
      render json: { error: "unable to destroy Todo" }, status: 500
  end

  private

  def valid_params
    params.require(:todo).permit(:title, :status, :is_completed)
  end
end
