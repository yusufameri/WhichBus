module WhichBus
  class Stop
    attr_reader :lat, :lon, :id, :title

    # holds information about a bus stop
    def initialize(lat, lon, id, title)
      @lat = lat
      @lon = lon
      @id = id
      @title = title
    end

    def get_position
      [@lat, @lon]
    end

  end
end
