class CouncilSync < ApplicationRecord
  belongs_to :council

  STATUSES = %w[waiting processing processed failed].freeze
  validates :status, inclusion: { in: STATUSES }

end
