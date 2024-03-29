class Integrations::ClassifyDocumentWorker
  attr_reader :document, :model

  include Sidekiq::Worker

  def perform(document_id, model = ENV['OPENAI_MODEL'])
    @document = Document.find(document_id)
    document.update!(processing_status: 'processing')

    # classify document with OpenAI
    openai_client = Integrations::OpenAi.new(model:)
    prompt = PromptGenerator.meeting_notes_classification(document.text)
    classification = openai_client.chat(prompt)

    # TODO: currently we are only classifying meeting notes, to determine if we should find primary information on the meeting
    # if false, there could be a follow-up pipeline to classify more kinds of document, and extract data from these
    if classification[:response].length == 0
      raise "Integrations::ProcessDocumentWorker encountered an error classifying a document using OpenAI's API."
    end

    # create classification
    document_metadata = JSON.parse(classification[:response].gsub(/(```json\n)|(```)|(\n)/, ''), symbolize_keys: true)
    document_classification = document.document_classifications.create!(
      input: prompt,
      input_token_count: classification[:input_tokens],
      output: document_metadata,
      output_token_count: classification[:output_tokens],
      model: classification[:model]
    )

    document.update!(processing_status: 'processed')

    if document_metadata['is_agenda']
      # add metadata to the right places
      document.update!(kind: 'meeting_notes')
      document.meeting.update!(
        about: document_metadata['about'],
        agenda: document_metadata['agenda'],
        decisions: document_metadata['decisions'],
        topline: document_metadata['topline']
      )
      document.meeting.apply_tags!(document_metadata['keywords'])
      document.meeting.upsert_attendees!(document_metadata['attendees'].split(',').map(&:strip))
    else
      document.update!(kind: 'other')
    end

    add_deeper_document_data!

    Integrations::Opensearch.new(mode: 'classification').index_object!(document_classification)
    document_classification
  end

  def add_deeper_document_data!
    openai_client = Integrations::OpenAi.new(model:)
    prompt = PromptGenerator2.meeting_notes_classification(document.text)
    classification = openai_client.chat(prompt)

    # TODO: currently we are only classifying meeting notes, to determine if we should find primary information on the meeting
    # if false, there could be a follow-up pipeline to classify more kinds of document, and extract data from these
    if classification[:response].length == 0
      raise "Integrations::ProcessDocumentWorker encountered an error classifying a document using OpenAI's API."
    end

    # create classification
    document_metadata = JSON.parse(classification[:response].gsub(/(```json\n)|(```)|(\n)/, ''), symbolize_keys: true)
    document_classification = document.document_classifications.create!(
      input: prompt,
      input_token_count: classification[:input_tokens],
      output: document_metadata,
      output_token_count: classification[:output_tokens],
      model: classification[:model]
    )
  end
end
