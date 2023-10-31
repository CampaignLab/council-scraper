class MeetingsController < ApplicationController
  def show
    @meeting = Meeting.includes(:documents).find(params[:id])
  end
end
