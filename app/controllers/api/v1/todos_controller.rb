class Api::V1::TodosController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    @todos = Todo.all
    render json: @todos
  end
  def show
    @todo = Todo.find(params[:id])
    render json: @todos
  end
  def create
    @todo = Todo.new(valid_params)
    if @todo.save
      render json: @todo, status: 200
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end
  def update
    @todo = Todo.find(params[:id])
    if @todo
      @todo.update!(valid_params)
      render json: { message: "Todo updated" }, status: 200
    else
      render json: { error: "unable to update Todo" }, status: 500
    end
  end
  def destroy
    @todo = Todo.find(params[:id])
    if @todo
      @todo.destroy
      render json: { message: "Todo destroyed" }, status: 200
    else
      render json: { error: "unable to destroy Todo" }, status: 500
    end
  end
  private
  def valid_params
    params.require(:todo).permit(:title, :status, :is_completed)
  end
end
