class ScrapeCouncilsWorker
  include Sidekiq::Worker

  def perform(num_weeks_back = 6)
    CSV.foreach('data/councils.csv', headers: true) do |row|
      council = Council.find_or_create_by!(external_id: row['id'])
      council.update!(name: row['name'], base_scrape_url: row['url'])
    end

    Council.where(id: [94, 209, 113, 162, 192]).each do |council|
      (0..num_weeks_back).each do |weeks_ago|
        date = Date.today - (weeks_ago * 7)
        beginning_of_week = date.beginning_of_week(:monday)

        ScrapeCouncilWorker.perform_async(council.id, beginning_of_week.to_s)
      end
    end
  end
end
