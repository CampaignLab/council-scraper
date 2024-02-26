class ClassifyCouncilWorker
  include Sidekiq::Worker

  def perform(council_id, beginning_of_week_str)
    council = Council.find(council_id)
    council_sync = CouncilSync.find_or_create_by!(council_id: council_id, week: beginning_of_week_str, kind: 'classify')
    council_sync.update!(status: 'processing')

    meetings = council.meetings.where(date: beginning_of_week_str.to_date..(beginning_of_week_str.to_date + 6.days))

    documents = meetings.map(&:documents).flatten
    documents.each_with_index do |document, i|
      puts "Classifying document #{i + 1} of #{documents.length}"
      Integrations::ClassifyDocumentWorker.new.perform(document.id)
    end

    council_sync.update!(status: 'processed', last_synced_at: Time.now.utc)
  end
end
