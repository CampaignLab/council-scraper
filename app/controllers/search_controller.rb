class SearchController < ApplicationController
  def index
    @query = params[:query]
    @council_id = params[:council_id]
    @mode = params[:mode] || 'document'

    if @query.present?
      filters = {}
      if @council_id.present?
        filters[:organisation_ids] = [@council_id]
      end
      @results = Integrations::Opensearch.new(mode: @mode).search(
        @query,
        filters
      )['hits']['hits'].map do |hit|
        hit['object'] = Document.find(hit['_source']['id'])
        hit
      end
    end
  end

  def search
  end
end
