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

      request = Net::HTTP::Get.new("#{BASE_URI}/routes/#{route_id}/")
      response = HTTP.request(request)

      parsed = JSON.parse response.body

      stops = parsed["stops"]
      stops.each do |stop|
        stops_hash[stop["id"]] = WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
      end
      stops_hash
    end

    def get_epoch_time(route_id, stopid)
      request = Net::HTTP::Get.new("#{BASE_URI}/routes/#{route_id}/stops/#{stopid}/predictions")
      response = HTTP.request(request)

      parsed = JSON.parse response.body
      epochtime = parsed[0]["values"][0]["epochTime"]
    end
  end
end
