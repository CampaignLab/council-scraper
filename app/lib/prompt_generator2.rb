class PromptGenerator2
  MAX_INPUT = 16_000 # this can be set longer, but be careful of model restrictions and cost!

  def self.meeting_notes_classification(document)
    text = document.slice(0, MAX_INPUT)

    prompt = <<-TEXT
          Here is the first part of a meeting from a council in the UK. Please read it, and then output the following answers, in JSON, with the keys listed in brackets by the questions:
          1 (attendees). Who attended this meeting? (Comma separated list of names). When answering this, please don't include anyone who is in the 'apologies' section. Only include people from the first section of attendees, then stop. No one mentioned lower down in the notes
          2 (decisions). What major decisions that were made which may be of interest to local campaigners or may be particularly contentious within the community - look specifically at details about any petitions submitted or public comments and any cabinet member decisions. Look for assets that are sold off, service restructuring and decisions around green spaces or housing. Please score how contentious this issue is on a scale of 0 to 10, where 0 is completely uncontroversial, and 10 where everyone in the local area will care about it. Also look for mentions of political parties, or political influence on the decision. Return an array of decision objects, with the following keys: summary, outcome, affected_stakeholders, reason_contentious, contentiousness_score, political_party_relevance

          -------

          #{text}
    TEXT
  end
end
