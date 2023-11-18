class Decision < ApplicationRecord
  belongs_to :council
  has_many :decision_classifications

  def classify!(model: nil)
    Integrations::ClassifyDecisionWorker.perform_async(self.id, model)
  end
end
