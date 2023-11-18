def do_council(name)
  council = Council.find_by!(name: name)
  (0..8).each do |weeks_ago|
    date = Date.today - (weeks_ago * 7)
    beginning_of_week = date.beginning_of_week(:monday)

    ScrapeCouncilWorker.perform_async(council.id, beginning_of_week.to_s)
  end

  ScrapeDecisionsWorker.perform_async(council.id)
end

def classify_council(name)  
  council = Council.find_by!(name: name)

  council.decisions.each do |decision|
    decision.classify!
  end

  council.meetings.each do |meeting|
    meeting.documents.each do |d|
      d.classify!
    end
  end
end
