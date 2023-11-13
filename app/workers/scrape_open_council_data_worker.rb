class ScrapeOpenCouncilDataWorker 
  include Sidekiq::Worker

  def perform
    load_councils!
    load_councillors!
  end

  def load_councils!
    body = get_file_from_url('http://opencouncildata.co.uk/csv1.php', 'tmp/councils.csv')

    CSV.parse(body, headers: true) do |row|
      council = Council.find_by(name: row["name"])
      next if council.nil?

      majority_party = row['majority']
      council.update!(majority_party: majority_party)
    end
  end

  def load_councillors!
    body = get_file_from_url('http://opencouncildata.co.uk/csv2.php?y=2023', 'tmp/councillors.csv')
    
    CSV.parse(body, headers: true) do |row|
      council = Council.find_by(name: row["council"])
      next if council.nil?

      ocd_id = row['councillorID']
      name = row['councillorName']
      party = row['partyName']
      
      councillor = Person.find_or_create_by!(ocd_id: ocd_id, council: council)
      councillor.update!(name: name, party: party, council: council, is_councillor: true)
    end
  end

  def get_file_from_url(url, file_path)
    if !File.exist?(file_path)
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      
      File.open(file_path, 'wb') do |file|
        file.write(response.body)
      end
    end

    body = File.open(file_path, 'r:bom|utf-8') { |file| file.read }
    body.force_encoding('UTF-8')
    body.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
