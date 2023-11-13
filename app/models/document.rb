class Document < ApplicationRecord
  belongs_to :meeting
  has_many :document_classifications

  PROCESSING_STATUSES = ['waiting', 'processing', 'processed', 'failed'].freeze
  DOCUMENT_KINDS = ['unclassified', 'meeting_notes', 'other'].freeze # TODO: expand classifications

  scope :processed, -> { where(processing_status: 'processed') }
  scope :unprocessed, -> { where(processing_status: 'waiting') }

  def extract_text!
    return if !pdf?
    return if text.present?

    puts "fetching #{self.url}"
    response = HTTParty.get(self.url)
    
    begin
      Tempfile.create(['downloaded', '.pdf']) do |temp_pdf|
        temp_pdf.write(response.body)
        temp_pdf.rewind

        # Extract text from the PDF
        reader = PDF::Reader.new(temp_pdf.path)
        text = reader.pages.map(&:text).join("
").gsub(/
{2,}/, "
") # trim any excess newlines
        update!(text: text, extract_status: 'success')
      end
    rescue PDF::Reader::MalformedPDFError => e
      update!(extract_status: 'failed')
    end
  end

  def pdf?
    url.to_s.split('?')[0].end_with?('.pdf')
  end

  def classify!(model: nil)
    Integrations::ClassifyDocumentWorker.perform_async(id, model)
  end
end
