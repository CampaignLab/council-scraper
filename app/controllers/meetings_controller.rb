require 'sidekiq/api'

class MeetingsController < ApplicationController
  def index
    @meetings = Meeting.includes(:council, :documents, :committee).order(date: :desc).limit(100)

    queue = Sidekiq::Queue.new # Default queue. You can specify a different queue by passing its name as an argument.
    @council_job_count = queue.select { |job| job.klass == 'ScrapeCouncilWorker' }.count
    queue = Sidekiq::Queue.new # Default queue. You can specify a different queue by passing its name as an argument.
    @meeting_job_count = queue.select { |job| job.klass == 'ScrapeMeetingWorker' }.count
  end
  
  def show
    @meeting = Meeting.includes(:documents).find(params[:id])
  end
end
