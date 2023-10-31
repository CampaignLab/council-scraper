class CouncilsController < ApplicationController
  def show 
    @council = Council.find(params[:id])
    @meetings = @council.meetings.includes(:council, :documents, :committee).order(date: :desc)
  end
end
