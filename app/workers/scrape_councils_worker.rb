class ScrapeCouncilsWorker
  NUM_WEEKS_BACK = 10
  
  include Sidekiq::Worker
  
  def perform
    CSV.foreach("data/councils.csv", headers: true) do |row|
      council = Council.find_or_create_by!(external_id: row["id"])
      council.update!(name: row["name"], base_scrape_url: row["url"])

      (0..NUM_WEEKS_BACK).each do |weeks_ago|
        date = Date.today - (weeks_ago * 7)
        beginning_of_week = date.beginning_of_week(:monday) - 1.week
        
        ScrapeCouncilWorker.perform_async(council.id, beginning_of_week.to_s)
      end
    end
  end
end
