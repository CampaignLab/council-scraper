class ScrapeMeetingWorker 
  attr_reader :base_domain

  include Sidekiq::Worker

  def perform(meeting_id)
    sleep CouncilScraper::GLOBAL_DELAY
    meeting = Meeting.find(meeting_id)

    @base_domain = 'https://' + URI(meeting.url).host
    puts "fetching #{meeting.url}"
    meeting_doc = get_doc(meeting.url)

    pdfs = get_printed_minutes(meeting_doc)
    pdfs.each do |pdf|
      document = meeting.documents.find_or_create_by!(url: pdf)
      document.update!(is_minutes: true)
      document.extract_text!
    end

    pdfs = recursive_get_pdfs(meeting_doc)
    pdfs.each do |pdf|
      document = meeting.documents.find_or_create_by!(url: pdf)
      document.update!(is_minutes: false)
      document.extract_text!
    end

    media = get_media(meeting_doc)
    media.each do |media_url|
      document = meeting.documents.find_or_create_by!(url: media_url)
      document.update!(is_media: true)
    end
  end

  def get_printed_minutes(doc)
    links = doc.css('.mgContent a, .mgActionList a')
      .select do |link| 
        link.content.downcase.include?('printed minutes') || link.content.downcase.include?('printed draft minutes') 
      end
      .map { |link| link['href'] }.compact.uniq

    if links.length > 1
      puts "FOUND IT"
    end

    links.map do |link| 
      clean_link = link.gsub(' ', '+')
      begin
        URI.join(base_domain, clean_link).to_s 
      rescue URI::InvalidURIError
        nil
      end
    end.compact
  end

  def recursive_get_pdfs(doc_or_url, depth = 0)
    sleep CouncilScraper::GLOBAL_DELAY

    return [] if doc_or_url.is_a?(String) && !doc_or_url.start_with?('http')
    if doc_or_url.is_a?(String)
      puts "fetching #{doc_or_url}"
      doc_or_url = get_doc(doc_or_url)
    end

    links = doc_or_url.css('.mgContent a, .mgLinks a').map { |link| link['href'].to_s }.compact.uniq.map do |link| 
      clean_link = link.gsub(' ', '+')
      begin
        URI.join(base_domain, clean_link).to_s 
      rescue URI::InvalidURIError
        nil
      end
    end.compact
    pp links
    links.map do |link|
      main_url = link.split('?')[0]
      if main_url.downcase.ends_with?('.pdf') || main_url.downcase.ends_with?('.doc') || main_url.downcase.ends_with?('.docx')
        puts link
        link
      elsif depth < 2 && !link.include?('mgMeetingAttendance.aspx') && !link.include?('mgLocationDetails.aspx') && !link.include?('mgIssueHistoryHome.aspx') && !link.include?('mgIssueHistoryChronology.aspx') && !link.include?('ieIssueDetails.aspx')
        recursive_get_pdfs(link, depth+1)
      else
        []
      end
    end.flatten.uniq
  end

  def get_media(doc)
    script_content = doc.search('script').find { |script| script.content.include?('mgMeetingMedia') }

    if script_content
      # Extract the JSON-like string
      json_string = script_content.content.match(/mgMeetingMedia = new mgMediaPlayer\(mgJQuery, "mgMeetingMedia", (\[.*?\])/m)[1]

      # Parse the JSON-like string into a Ruby array
      media_info = JSON.parse(json_string)

      # Extract URLs
      return media_info.map { |media| media['Url'] }
    end

    []
  end

  def get_doc(url)
    uri = URI(url)
    host = uri.host
    response = Net::HTTP.get_response(uri)
    Nokogiri::HTML(response.body)
  end
end
