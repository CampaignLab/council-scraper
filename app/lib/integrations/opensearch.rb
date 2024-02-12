require 'opensearch-aws-sigv4'
require 'aws-sigv4'

class Integrations::Opensearch
  attr_reader :api_client

  def initialize
    if ENV['RAILS_ENV'] == 'development'
      @api_client = OpenSearch::Client.new({
        host: 'http://localhost:9200', # The local OpenSearch instance address
        log: true
      })
    else
      signer = Aws::Sigv4::Signer.new(service: 'es',
                                      region: ENV['AWS_OPENSEARCH_REGION'],
                                      access_key_id: ENV['AWS_OPENSEARCH_ACCESS_KEY_ID'],
                                      secret_access_key: ENV['AWS_OPENSEARCH_SECRET_KEY'])

      @api_client = OpenSearch::Aws::Sigv4Client.new({
          host: ENV['AWS_OPENSEARCH_HOST'],
          log: true
      }, signer)
    end
  end

  def search(query, organisation_ids = [])
    bool = {
      must: {
        multi_match: {
          query: query,
          fields: ['*'],
          type: 'best_fields'
        }
      }
    }

    if organisation_ids.present?
      bool[:filter] = {
        terms: {
          organisation_ids: organisation_ids
        }
      }
    end

    api_client.search(index: index_name, body: {
      query: {
        bool: bool
      },
      highlight: {
        fields: {
          '*' => {} # Apply highlighting to all fields
        },
        fragment_size: 50, # The size of the highlighted fragment in characters
        number_of_fragments: 1, # The number of fragments returned per field
        post_tags: ["</strong>"], # Define the tag used to highlight the matching query terms
        pre_tags: ["<strong>"] # Define the tag used to highlight the matching query terms
      }
    })
  end

  def create_index!
    if api_client.indices.exists(index: index_name)
      return false
    end

    # rubocop:disable Rails/SaveBang
    api_client.indices.create(index: index_name)
    # rubocop:enable Rails/SaveBang

    true
  end

  def delete_index!
    api_client.indices.delete(index: index_name)
  end

  def index_object!(object)
    document = object_representation(object)
    return if document.nil?

    api_client.index(
      index: index_name,
      body: object_representation(object),
      id: "#{object.class.name}-#{object.id}",
      refresh: true
    )
  end

  def object_representation(object)
    if object.is_a?(Document)
      { id: object.id, name: object.name, type: object.class.name, text: object.text, organisation_ids: [object.meeting.council_id] }
    else
      raise UnknownObjectError, "Don't know how to index a #{object.class.name}"
    end
  end

  def index_name
    "#{ENV['AWS_OPENSEARCH_PREFIX']}-search"
  end

  class UnknownObjectError < StandardError; end
end
