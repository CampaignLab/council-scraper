class Integrations::ClassifyDecisionWorker
  include Sidekiq::Worker

  def perform(decision_id, model = nil)
    model = model || ENV['OPENAI_MODEL']
    
    decision = Decision.find(decision_id)
    # classify document with OpenAI
    openai_client = Integrations::OpenAi.new(model:)

    content =<<~TEXT 
      DECISION MAKER: #{decision.decision_maker}
      DECISION_OUTCOME: #{decision.outcome}

      #{decision.content}
    TEXT

    prompt = PromptGeneratorDecision.meeting_notes_classification(content)
    classification = openai_client.chat(prompt)

    # TODO: currently we are only classifying meeting notes, to determine if we should find primary information on the meeting
    # if false, there could be a follow-up pipeline to classify more kinds of document, and extract data from these
    if classification[:response].length == 0
      raise "Integrations::ProcessDocumentWorker encountered an error classifying a document using OpenAI's API."
    end

    # create classification
    document_metadata = JSON.parse(classification[:response].gsub(/(```json\n)|(```)|(\n)/, ''), symbolize_keys: true)
    decision_classification = decision.decision_classifications.create!(
      input: prompt,
      input_token_count: classification[:input_tokens],
      output: document_metadata,
      output_token_count: classification[:output_tokens],
      model: classification[:model]
    )
  end
end
