require_relative "../lib/which_bus.rb"


require "net/http"
require "uri"
require 'json'
require 'geocoder'
require "yaml"


bus_stops = [] # array of WhichBus::Stop

uri = URI.parse("http://restbus.info")
http = Net::HTTP.new(uri.host, uri.port)
BASE_URI = "/api/agencies/umd"

request = Net::HTTP::Get.new("#{BASE_URI}/routes/115/")
response = http.request(request)

parsed = JSON.parse response.body

stops = parsed["stops"]
stops.each do |stop|
  bus_stops << WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
end

puts "The buses for 115 Orange #{bus_stops.size}"
bus_stops.each do |stop|
  puts stop.title
end
