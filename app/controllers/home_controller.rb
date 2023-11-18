class HomeController < ApplicationController
  def index
    meetings = assemble_meetings
    decisions = assemble_decisions

    # Tag each item with its type and combine the arrays
    tagged_meetings = meetings.map { |item| { kind: 'meeting', item: item } }
    tagged_decisions = decisions.map { |item| { kind: 'decision', item: item } }
    combined_items = tagged_meetings + tagged_decisions

    # Sort the combined array by the created_at attribute of each item
    @feed_items = combined_items.sort_by { |hash| hash[:item].created_at }.reverse
  end

  private

  def assemble_meetings
    Meeting.order(id: :desc).take(10)
  end

  def assemble_decisions
    Decision.order(id: :desc).take(10)
  end
end
