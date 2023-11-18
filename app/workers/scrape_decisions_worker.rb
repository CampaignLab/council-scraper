class ScrapeDecisionsWorker
  attr_reader :council

  include Sidekiq::Worker

  def perform(council_id)
    @council = Council.find(council_id)

    # url = make_url
    # puts "fetching #{url}"
    # doc = get_doc(url)

    # links = doc.css('a[href^="ieDecisionDetails"]').map { |link| URI.join(url, link['href']).to_s }

    links = ['https://democracy.cambridge.gov.uk/ieDecisionDetails.aspx?ID=5403']

    links.each do |link|
      scrape_decision(link)
    end
  end

  def scrape_decision(url)
    # Parse the HTML content
    doc = get_doc(url)
    decision = Decision.find_or_create_by!(url: url, council: council)
  
    # Initialize a hash to store the extracted data
    decision_data = {
      council_id: nil, # This should be set based on your application logic
      url: nil,
      decision_maker: nil,
      outcome: nil,
      is_key: false, # Default value, update as per logic
      is_callable_in: false, # Default value, update as per logic
      purpose: nil,
      content: nil,
      date: nil
    }
  
    # Extract data
    decision_data[:url] = url
    decision_data[:decision_maker] = doc.css('.mgContent .mgLabel').find { |n| n.text == 'Decision Maker: ' }&.next_element&.text
    decision_data[:outcome] = doc.css('.mgContent .mgPlanItemInForce')&.text
    decision_data[:purpose] = doc.css('h3.mgSubSubTitleTxt').find { |n| n.text == 'Purpose:' }&.next_element&.text
    decision_data[:content] = doc.css('.WordSection1').text.strip
  
    date_text = doc.css('.mgContent').text.match(/Date of decision: (\d{2}\/\d{2}\/\d{4})/)&.captures&.first
    decision_data[:date] = Date.strptime(date_text, '%d/%m/%Y') if date_text
  
    decision.update!(decision_data)
  end

  def make_url
    start_date_str = (Time.now.utc - 1.year).strftime("%d-%m-%Y").gsub('-', '%2f')
    end_date_str = Time.now.utc.strftime("%d-%m-%Y").gsub('-', '%2f')
    
    council.base_scrape_url.gsub("mgCalendarMonthView.aspx", "mgDelegatedDecisions.aspx") + "?XXR=0&&DR=#{start_date_str}-#{end_date_str}&ACT=Find&RP=0&K=0&V=0&DM=0&HD=0&DS=2&Next=true&NOW=18112023122701&META=mgdelegateddecisions"
  end

  def get_doc(url)
    uri = URI(url)
    host = uri.host
    response = Net::HTTP.get_response(uri)
    Nokogiri::HTML(response.body)
  end
end
