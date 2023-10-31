class Meeting < ApplicationRecord
  belongs_to :council
  belongs_to :committee, optional: true
  has_many :documents
end
