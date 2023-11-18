class PromptGeneratorDecision
  MAX_INPUT = 16_000 # this can be set longer, but be careful of model restrictions and cost!

  def self.meeting_notes_classification(document)
    text = document.slice(0, MAX_INPUT)

    prompt = <<-TEXT
          This is the record of a decision made by a UK council. Please summarise, return a JSON object, with the following keys: 
          (summary) What is at stake in the decision?
          (outcome) What was the outcome of the decision?
          (reason_contentious) Taking into account local stakeholders, political issues, is this issue contentious? If so why?
          (contentiousness_score) On a scale of 0 to 10 how contentious is this?
          (affected_stakeholders) Which stakeholders are affected by this decision?
          (political_party_relevance) Are there any mentions or implication of political parties, or political influence on the decision?
          (topline) A topline, singular sentence, as if written as the start of a newspaper article. Should always resemble: "The {decision_maker} has decided to {summation of decision}"

          -------

          #{text}
    TEXT
  end
end
