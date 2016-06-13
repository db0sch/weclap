class SearchController < ApplicationController

  def index
    search_terms = params[:terms]
    # search imdb for the terms, possibly background job with high priority

    # retrieve the items list: only movies for now (but later, collections & people)
    # search whether they are present in the DB: if not add from within another background job
    # bring back the results to the requester ordered by desc release_date
  end
end
