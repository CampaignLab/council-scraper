class Council < ApplicationRecord
  has_many :meetings
  has_many :decisions
  has_many :committees
  has_many :people, class_name: 'Person'
end
