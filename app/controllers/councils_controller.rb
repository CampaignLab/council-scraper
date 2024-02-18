class CouncilsController < ApplicationController
  def index
    @councils = Council.all.order(:name)
  end

  def show
    @council = Council.find(params[:id])
    @meetings = @council.meetings.includes(:council, :documents, :committee).order(date: :desc).take(10)
    @decisions = @council.decisions.includes(:council, :decision_classifications).order(date: :desc).take(10)
  end
end
