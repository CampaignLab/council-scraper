class HomeController < ApplicationController
  def index
    @council = council_from_params || nil
    @feed_items = assemble_feed_items(@council)
  end

  private

  def council_from_params
    Council.find_by(id: params[:council_id]) if params[:council_id].present?
  end

  def assemble_feed_items(council)
    items = [assemble_meetings(council), assemble_decisions(council)].flatten
    tag_and_sort_items(items)
  end

  def assemble_meetings(council)
    scope = council ? council.meetings : Meeting
    scope.order(id: :desc).limit(10)
  end

  def assemble_decisions(council)
    scope = council ? council.decisions : Decision
    scope.order(id: :desc).limit(10)
  end

  def tag_and_sort_items(items)
    items.map { |item| tag_item(item) }
         .sort_by { |hash| -hash[:item].created_at.to_i }
  end

  def tag_item(item)
    kind = item.is_a?(Meeting) ? 'meeting' : 'decision'
    { kind: kind, item: item }
  end
end
