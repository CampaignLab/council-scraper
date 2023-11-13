class Council < ApplicationRecord 
  has_many :meetings
  has_many :committees
end
