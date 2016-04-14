# use this class to define methods that involve api calss
require "yaml"

module WhichBus
  class APIMethods
    attr_reader :uri, :http, :base_uri

    def initialize
       @uri = URI.parse("http://restbus.info")
       @http = Net::HTTP.new(@uri.host, @uri.port)
       @base_uri = "/api/agencies/umd"
    end

    # return a hash of stops that are on the route_id. Access hashes with key of
    # the stop_if
    def get_stops_for_route(route_id)
      stops_hash = Hash.new

      request = Net::HTTP::Get.new("#{@base_uri}/routes/#{route_id}/")
      response = @http.request(request)

      parsed = JSON.parse response.body

      stops = parsed["stops"]
      stops.each do |stop|
        stops_hash[stop["id"]] = WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
      end
      stops_hash
    end

    # returns an array full of all umd route_ids
    def get_routes
      routes = []
      request = Net::HTTP::Get.new("#{@base_uri}/routes/")
      response = @http.request(request)

      parsed = JSON.parse response.body
      parsed.each do |route|
        routes << route["id"]
      end
      routes
    end

    # saves an array of hashes for all of the stops
    def get_all_stops
      routes = get_routes
      stops = Hash.new
      routes.each do |route_id|
        route_stops = get_stops_for_route(route_id)
        route_stops.each do |stopid, stop|
          stops[stopid] = stop
        end
      end
      stops
    end

    # saves information about stops hash to bus_stops.txt
    def save_stops
      stops = get_all_stops
      yaml = YAML.dump(stops)
      File.open("lib/bus_stop_file/bus_stops.txt", 'w') do |file|
        file.write(yaml)
      end
    end

    # loads the stops hash from bus_stops.txt
    def stops_hash
      saved_stops = File.open("lib/bus_stop_file/bus_stops.txt", 'r')
      yaml = saved_stops.read
      stops = YAML.load(yaml)
    end

    def get_closest_stop(user_coordinate)
      closest_stop = nil
      user_coordinate = [user_coordinate[:lat], user_coordinate[:lon]]
      closest_distance = 1000 # a randomly large number
      stops = stops_hash
      stops.each do |stopid, stop|
        stop_coordinate = [stop.lat, stop.lon]
        calculated_distance = distance_between(user_coordinate, stop_coordinate)

        if calculated_distance < closest_distance
          closest_distance = calculated_distance
          closest_stop = stop
        end
      end
      return closest_stop
    end

    # returns an array/list of all routes that go through a stopid
    def get_routes_on_bus_stop(stopid)
      all_routes = get_routes
      routes_on_bus_stop = []

      all_routes.each do |route_id|
        route_stops = get_stops_for_route(route_id)
        if route_stops.include? stopid
          routes_on_bus_stop << route_id
        end
      end
      routes_on_bus_stop
    end

    # same as above but with (using api.umd.io). This is significantly faster
    def find_routes(stop_id)
      unless stop_id
        puts "stop_id cannot be nil"
      end

      uri = URI.parse("http://api.umd.io")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Get.new("/v0/bus/routes")
      response = http.request(request)

      parsed = JSON.parse response.body

      # puts "Number of routes: #{parsed.size}"

      good_route_ids = []

      parsed.each do |route|
        # Go through each route
        route_id = route["route_id"]
        request = Net::HTTP::Get.new("/v0/bus/routes/"+route_id)
        response = http.request(request)

        parsed = JSON.parse response.body

        if parsed["stops"]
          parsed["stops"].each do |stop|
            if(stop["stop_id"] == stop_id)
              good_route_ids << parsed["route_id"]
              # puts "This route(#{parsed["title"]}) stops at #{stop["title"]}. The route_id is #{parsed["route_id"]}"
            end
          end
        end
      end
      return good_route_ids
    end

    # returns an array of buses that that go to both of the stops
    def common_buses(start_stop, end_stop)
      find_routes(start_stop) & find_routes(end_stop)
    end

    # returns an array of estimated epochTimes for a route at a stop
    def get_epoch_times(route_id, stopid)
      request = Net::HTTP::Get.new("#{@base_uri}/routes/#{route_id}/stops/#{stopid}/predictions")
      response = @http.request(request)

      parsed = JSON.parse response.body
      if parsed.empty? || parsed[0].nil?
        puts "Sorry, the bus with route_id: #{route_id}, is not running at the time :("
        return nil
      end
      details = parsed[0]["values"]
      times = []
      details.each do |detail|
        # for some reason we have to ignore the last 3 digits. idk why?
        times << detail["epochTime"].to_s[0..-4].to_i
      end
      return times
    end

    def estimated_arrival_time(route_id, start_stopid, end_stopid)
      leave_times = get_epoch_times(route_id, start_stopid)
      arrive_times = get_epoch_times(route_id, end_stopid)

      now_time = Time.now

      bus_leave_time = leave_times.first
      bus_arrive_time = arrive_times.first
      i = 0
      while (bus_leave_time > bus_arrive_time)
        i+=1
        bus_arrive_time = arrive_times[i]
      end
      # puts "The Current Time is: #{(Time.at now_time).asctime}"
      # puts "The bus #{route_id}, will be leaving from #{start_stopid} at #{Time.at(bus_leave_time).asctime}"
      # puts "You can expect to arrive to #{end_stopid} at #{Time.at(bus_arrive_time).asctime}"
      array = [now_time.to_i, Time.at(bus_leave_time).asctime, Time.at(bus_arrive_time).asctime, bus_arrive_time]
      array << now_time.to_i
      # return bus_arrive_time # returns the estimated epochTime of arrival
    end

    def which_bus(start_coordinate, end_coordinate)
      start_stop = get_closest_stop(start_coordinate)
      end_stop = get_closest_stop(end_coordinate)

      common_routes = Array.new
      # puts "start_stop: #{start_stop}, end_stop: #{end_stop}"
      common_routes = common_buses(start_stop.id, end_stop.id)
      # p common_routes
      if common_routes.nil? || common_routes.empty?
        puts "sorry, there are CURRENTLY no common routes between #{start_stop.id} and #{end_stop.id}"
        return nil
      end
      earliest_arrival_time = Time.now.to_i + 10000
      arrival_time_with_route = estimated_arrival_time(common_routes.first, start_stop.id, end_stop.id)
      route_id = ""
      common_routes.each do |route|
        arrival_time_with_route = estimated_arrival_time(route, start_stop.id, end_stop.id)
        if arrival_time_with_route[-1] < earliest_arrival_time
          earliest_arrival_time = arrival_time_with_route[-1]
          route_id = route
        end
      end

      now_time = arrival_time_with_route[0]
      bus_leave_time = arrival_time_with_route[1]
      bus_arrive_time = arrival_time_with_route[2]

      puts "The Current Time is: #{(Time.at now_time).asctime}"
      puts "The bus #{route_id}, will be leaving from #{start_stop.title} at #{bus_leave_time}"
      puts "You can expect to arrive to #{end_stop.title} at #{bus_arrive_time}"
      # return [Time.at(now_time).asctime, Time.at(bus_leave_time).asctime, Time.at(bus_arrive_time).asctime, bus_arrive_time]
      # return bus_arrive_time # returns the estimated epochTime of arrival


    end

    private
    def distance_between(point1, point2)
      Geocoder::Calculations::distance_between(point1, point2, :units => :mi)
    end
  end
end
