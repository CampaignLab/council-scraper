class ScrapeCouncilWorker
  include Sidekiq::Worker

  def perform(council_id, beginning_of_week_str)
    sleep CouncilScraper::GLOBAL_DELAY
    council = Council.find(council_id)
    beginning_of_week = Date.parse(beginning_of_week_str)

    url = make_url(council.base_scrape_url, beginning_of_week)
    puts "fetching #{url}"
    base_domain = 'https://' + URI(url).host
    doc = get_doc(url)

    puts beginning_of_week
    7.times do |day|
      block = doc.css('.mgCalendarWeekGrid')[day]
      next if block.nil?

      links = block.css('a').map { |link| URI.join(base_domain, link['href']).to_s }

      links.each do |link|
        puts "fetching #{link}"
        doc = get_doc(link)
        name = doc.css('.mgSubTitleTxt').text
        committee_name = name.split(' - ')[0]
        committee = council.committees.find_or_create_by!(name: committee_name)

        meeting = council.meetings.find_or_create_by!(url: link)
        meeting.update!(name:, committee:, date: beginning_of_week + day.days)

        ScrapeMeetingWorker.perform_async(meeting.id)
      end
    end
  end

  def get_doc(url)
    uri = URI(url)
    host = uri.host
    response = Net::HTTP.get_response(uri)
    Nokogiri::HTML(response.body)
  end

  def make_url(url, beginning_of_week)
    week_number = beginning_of_week.strftime('%W').to_i
    year = beginning_of_week.strftime('%Y').to_i

    url.gsub('mgCalendarMonthView.aspx',
             'mgCalendarWeekView.aspx') + "?WN=#{week_number}&CID=0&OT=&C=-1&MR=0&DL=0&ACT=Later&DD=#{year}"
  end
end
