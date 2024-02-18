class SearchController < ApplicationController
  def index
    if params[:query].present?
      filters = {}
      if params[:council_id].present?
        filters[:organisation_ids] = [params[:council_id]]
      end
      @results = Integrations::Opensearch.new.search(
        params[:query],
        filters
      )['hits']['hits'].map do |hit|
        hit['object'] = Document.find(hit['_source']['id'])
        hit
      end
      @query = params[:query]
      @council_id = params[:council_id]
    end
  end

  def search
  end
end
