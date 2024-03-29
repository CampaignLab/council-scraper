class PromptGenerator
  MAX_INPUT = 16_000 # this can be set longer, but be careful of model restrictions and cost!

  def self.meeting_notes_classification(text)
    text = text.slice(0, MAX_INPUT)

    prompt = <<-TEXT
          Here is the first part of a meeting from a council in the UK. Please read it, and then output the following answers, in JSON, with the keys listed in brackets by the questions:
          1 (attendees). Who attended this meeting? (Comma separated list of names). When answering this, please don't include anyone who is in the 'apologies' section. Only include people from the first section of attendees, then stop. No one mentioned lower down in the notes
          2 (about). What is this meeting about, if it appears to describe a meeting? If this is an appendix or supporting document, what is it about?
          3 (agenda). Sum up the agenda contained in a few sentences. If there is no clearly labelled agenda, return a blank string
          4 (keywords). List up to 5 keywords which cover the topics of this meeting. All keywords should be 1 word, and be very topline, e.g. 'Planning', 'Licensing', 'Executive'. Only return tags which are very topline, returning 1 is fine if the meeting is only about 1 thing
          5 (decisions). List the most important few decisions made, if the document does contain any decisions. Otherwise an empty array
          6 (is_agenda). A true/false indicator of whether this contains an agenda of the meeting, 'true' if so, 'false' if it appears to be an appendix, supporting documents, without explicitly saying it is an agenda, or supporting agenda
          7 (has_attendees). A true/false indicator of whether this contains a list of attendees. 'true' if so, 'false' if not. This must be a labelled list of 'Present', or 'Attendees'
          8 (has_decisions). A true/false indicator of whether this contains decisions made, 'true' if so, 'false' if not. This must clearly be outcomes, decisions
          9 (topline). A topline, singular sentence, as if written as the start of a newspaper article. Should always resemble: "The {committee} met to {discuss/decide} {the key decisions/meeting content}"
          -------

          #{text}
    TEXT
  end
end
