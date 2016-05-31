class StreamingsJobController < AbstractController::Base
  include AbstractController::Rendering
  include ActionView::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  self.view_paths = "app/views"

  def index(streamings)
    render partial: "movies/streamings", locals: { streamings: streamings }
  end
end
