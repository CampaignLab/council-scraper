class Council < ApplicationRecord
  has_many :meetings
  has_many :committees
  has_many :people, class_name: 'Person', foreign_key: 'council_id'
end
