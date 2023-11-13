class Person < ApplicationRecord
  belongs_to :council
  has_many :person_meetings

  # TODO: implement fuzzy match function
  def self.fuzzy_match(input)
    #
  end
end
