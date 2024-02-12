class SearchController < ApplicationController
  def index
    if params[:query].present?
      @results = Integrations::Opensearch.new.search(params[:query])['hits']['hits'].map do |hit|
        hit['object'] = Document.find(hit['_source']['id'])
        hit
      end
    end
  end

  def search

  end
end
