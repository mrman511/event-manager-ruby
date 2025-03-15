class EventsController < ApplicationController
  # protect_from_forgery with: :null_session

  def index
    render json: Event.all
  end

  def show
    render json: Event.find(params[:id])
  end

  def create
    event = Event.create(permitted_params)
    if event.valid?
      render json: event, status: :accepted
    else
      render json: event.errors, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find(params[:id])
    if event and !permitted_params.empty?
      event.update!(permitted_params)
      render json: event, status: :accepted
    else
      render json: event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find(params[:id])
    if event
      event.destroy
      render json: { message: "event destroyed" }, status: :ok
    else
      render json: event.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:title, :tagline, :description, :postscript, :starts, :ends, :location)
  end
end
