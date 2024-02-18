class Decision < ApplicationRecord
  belongs_to :council
  has_many :decision_classifications

  scope :in_last, ->(days) { where('created_at >= ?', days.days.ago) }

  def classify!(model: nil)
    Integrations::ClassifyDecisionWorker.perform_async(self.id, model)
  end

  def color 
    score = decision_classifications.last&.output.try(:[], 'contentiousness_score').to_i
    if score <= 3
      '#bfb'
    elsif score <= 6
      '#ffb'
    else
      '#fbb'
    end
  end
end
