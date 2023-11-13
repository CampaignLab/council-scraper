class Meeting < ApplicationRecord
  belongs_to :council
  belongs_to :committee, optional: true
  has_many :documents
  has_many :person_meetings
  has_many :meeting_tags

  def apply_tags!(tags)
    tags.each do |tag|
      MeetingTag.find_or_create_by!(meeting: self, tag: Tag.find_or_create_by!(tag: tag))
    end
  end

  def add_attendees!(attendees)
    # TODO: try and fuzzy match the list to people who belong to this committee/council (which need importing first, e.g. councillors)
    # this function will currently just upsert the list onto the attendees list on the meeting, which ideally would just be 3rd parties
    update!(additional_attendees: additional_attendees + attendees - additional_attendees)
  end
end
