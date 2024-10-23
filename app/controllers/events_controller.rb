class EventsController < ApplicationController
  # protect_from_forgery with: :null_session

  def index
    render json: Event.all
  end

  def show
    render json: Event.find(params[:id])
  end

  def create
    host = Host.find_by_id(params[:host])
    if !host || permitted_params.empty?
      render json: { message: "invalid request" }, status: :bad_request
    else
      event = host.create_event(permitted_params)
      if event.errors.count == 0
        render json: event, status: :accepted
      else
        render json: event.errors, status: :unprocessable_entity
      end
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
    event = Event.find_by_id(params[:id])
    if event
      host = Host.find(event.host_id)
      host.delete_event(params[:id])
      render json: { message: "event destroyed" }, status: :ok
    else
      render json: { message: "invalid request" }, status: :bad_request
    end
  end

  private

  def permitted_params
    if params[:event]
      params[:event].permit(:title, :tagline, :description, :postscript, :starts, :ends, :location)
    else
      []
    end
  end
end
