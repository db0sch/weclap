module MoviesHelper
  def build_markers_for_shows(shows)
    theaters = @shows.map { |theater, showtimes| theater }
    @markers = Gmaps4rails.build_markers(theaters) do |theater, marker|
      if theater.latitude && theater.longitude
        marker.lat theater.latitude
        marker.lng theater.longitude
      end
    end
  end
end
