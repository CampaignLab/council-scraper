class DocumentClassification < ApplicationRecord
  belongs_to :document
  has_one :meeting, through: :document
end
