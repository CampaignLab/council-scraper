class MeetingTag < ApplicationRecord
  belongs_to :tag
  belongs_to :meeting
end
