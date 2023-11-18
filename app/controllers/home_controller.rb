class HomeController < ApplicationController
  def index
    @council = council_from_params || nil
    @tag = tag_from_params || nil
    @feed_items = assemble_feed_items(@council, @tag)
  end

  private

  def tag_from_params
    Tag.find_by(id: params[:tag_id]) if params[:tag_id].present?
  end

  def council_from_params
    Council.find_by(id: params[:council_id]) if params[:council_id].present?
  end

  def assemble_feed_items(council, tag)
    items = [assemble_meetings(council, tag), assemble_decisions(council)].flatten
    tag_and_sort_items(items)
  end

  def assemble_meetings(council, tag)
    scope = council ? council.meetings.with_minutes : Meeting.with_minutes
    scope = scope.joins(:meeting_tags).where(meeting_tags: { tag_id: tag.id }) if tag
    scope.where.not(date: nil).order(date: :desc).limit(10)
  end

  def assemble_decisions(council)
    scope = council ? council.decisions : Decision
    scope.where.not(date: nil).order(date: :desc).limit(10)
  end

  def tag_and_sort_items(items)
    items.map { |item| tag_item(item) }
         .sort_by { |hash| -(hash[:item].date.to_time.to_i) }
  end

  def tag_item(item)
    kind = item.is_a?(Meeting) ? 'meeting' : 'decision'
    { kind: kind, item: item }
  end
end
