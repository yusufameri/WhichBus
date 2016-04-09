# use this class to define methods that involve api calss

module WhichBus
  class APIMethods
    attr_reader :uri, :http, :base_uri

    def initialize
       @uri = URI.parse("HTTP://restbus.info")
       @http = Net::HTTP.new(@uri.host, @uri.port)
       @base_uri = "/api/agencies/umd"
    end

    # return a hash of stops that are on the route_id. Access hashes with key of
    # the stop_if
    def get_stops(route_id)
      stops_hash = Hash.new

      request = Net::HTTP::Get.new("#{BASE_URI}/routes/117/")
      response = HTTP.request(request)

      parsed = JSON.parse response.body

      stops = parsed["stops"]
      stops.each do |stop|
        stops_hash[stop["id"]] = WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
      end
      stops_hash
    end
  end
end
