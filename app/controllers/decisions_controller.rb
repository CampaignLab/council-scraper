require 'sidekiq/api'

class DecisionsController < ApplicationController
  def index 
    @decisions = Decision.includes(:council).order(date: :desc).limit(100)
  end

  def show
    @decision = Decision.find(params[:id])
  end
end
