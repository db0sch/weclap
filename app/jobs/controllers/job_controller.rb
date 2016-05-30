class JobController < AbstractController::Base
 include AbstractController::Rendering
 include ActionView::Layouts
 include AbstractController::Helpers
 include AbstractController::Translation
 include AbstractController::AssetPaths
 self.view_paths = "app/views"

 def index(shows)
  render partial: "movies/shows", locals: { shows: shows }
 end
end
