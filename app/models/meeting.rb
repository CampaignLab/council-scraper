class Meeting < ApplicationRecord
  belongs_to :council
  belongs_to :committee, optional: true
  has_many :documents
  has_many :person_meetings
  has_many :meeting_tags
  
  scope :with_minutes, -> { 
    joins(:documents).where(documents: { is_minutes: true })
  }

  def apply_tags!(tags)
    tags.each do |tag|
      MeetingTag.find_or_create_by!(meeting: self, tag: Tag.find_or_create_by!(tag:))
    end
  end

  def upsert_attendees!(attendees)
    string_matcher = StringMatcher.new(strings: council.people.pluck(:id, :name))
    unmatched_attendees = []
    attendees.each do |attendee|
      if matched_person = string_matcher.match(input: attendee, threshold: 5)
        person_meetings.find_or_create_by!(person: Person.find(matched_person[:id]))
      else
        unmatched_attendees << attendee
      end
    end

    update!(additional_attendees: additional_attendees + unmatched_attendees - additional_attendees)
  end
end
