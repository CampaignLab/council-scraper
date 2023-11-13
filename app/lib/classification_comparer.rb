class ClassificationComparer
    attr_reader :document

    MODELS = [
        'gpt-3.5-turbo-1106',
        'gpt-4-1106-preview'
    ]

    def initialize(document_id)
        @document = Document.find(document_id)
    end

    def compare
        classification_1 = find_classification(MODELS[0])
        classification_2 = find_classification(MODELS[1])

        # compare attendees
        ['about', 'agenda', 'keywords', 'attendees', 'decisions', 'is_agenda', 'has_attendees', 'has_decisions'].each do |key|
            compare_jsons(key, classification_1.output, classification_2.output)
        end
    end

    def find_classification(model)
        classification = DocumentClassification.where(model: model, document: document).first
        if classification.nil?
            classification = Integrations::ClassifyDocumentWorker.new.perform(document.id, model)
        end
        classification
    end

    def compare_jsons(key, json1, json2)
        if [true, false].include?(json1[key])
          # Boolean comparison
          if json1[key] == json2[key]
            puts "#{key}: Matches".green
          else
            puts "#{key}: Does not match".red
          end
        elsif key == 'attendees'
          attendees1 = json1[key].split(', ').sort
          attendees2 = json2[key].split(', ').sort
      
          missing_in_1 = attendees2 - attendees1
          extra_in_1 = attendees1 - attendees2
      
          puts "#{key}: Count matches".green if attendees1.count == attendees2.count
          puts "#{key}: Count does not match".red if attendees1.count != attendees2.count
          puts "Block 1: Extra: #{extra_in_1.join(', ')}" unless extra_in_1.empty?
          puts "Block 2: Extra: #{missing_in_1.join(', ')}" unless missing_in_1.empty?
        else
          # Print about/agenda/decisions without comparison
          puts "#{key} for Block 1: #{json1[key]}"
          puts "#{key} for Block 2: #{json2[key]}"
        end
    end
end