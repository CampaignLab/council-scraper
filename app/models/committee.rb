class Committee < ApplicationRecord
  belongs_to :council
  has_many :meetings
end
