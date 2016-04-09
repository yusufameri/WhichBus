require_relative "../lib/which_bus.rb"
require "pp"
require "uri"
require 'json'
require "net/http"
require 'dijkstra'



# stops_116 = [] # bust stops in order of 116 Purple
stops_117 = Hash.new # bus stops in order of 117 Blue
nodes_117 = Hash.new

uri = URI.parse("http://restbus.info")
http = Net::HTTP.new(uri.host, uri.port)
BASE_URI = "/api/agencies/umd"

# request = Net::HTTP::Get.new("#{BASE_URI}/routes/116/")
# response = http.request(request)
#
# parsed = JSON.parse response.body
#
# stops = parsed["stops"]
# stops.each do |stop|
#   stops_116 << WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
# end

request = Net::HTTP::Get.new("#{BASE_URI}/routes/117/")
response = http.request(request)

parsed = JSON.parse response.body

stops = parsed["stops"]
# add all stops to the stops_117 hash
stops.each do |stop|
  stops_117[stop["id"]] = WhichBus::Stop.new(stop["lat"], stop["lon"], stop["id"], stop["title"])
end


# make the graph


# make node objects for all bus stops and put them in the nodes_117 hash
stops_117.each_with_index do |stop, index|
  nodes_117["#{stop[1].id}"] = WhichBus::Node.new("#{stop[1].title}", stop[1])
end

r = [
  [nodes_117["stamsuhh_d"], nodes_117["hoff"] , 5],
  [nodes_117["hoff"], nodes_117["uniofiel"], 9],
  [nodes_117["uniofiel"], nodes_117["biofield"], 8],
  [nodes_117["biofield"], nodes_117["mitc_out"], 1],
  [nodes_117["mitc_out"], nodes_117["memo_out"], 5],
  [nodes_117["memo_out"], nodes_117["mont_out"], 4],
  [nodes_117["mont_out"], nodes_117["baltritc"], 3],
  [nodes_117["memo_out"], nodes_117["mont_out"], 4],
  [nodes_117["mont_out"], nodes_117["baltritc"], 3],
  [nodes_117["baltritc"], nodes_117["mitc_out"], 1],
  [nodes_117["baltpbra"], nodes_117["univclub"], 9],
  [nodes_117["univclub"], nodes_117["berwuniv"], 4],
  [nodes_117["berwuniv"], nodes_117["univview"], 2],
  [nodes_117["univview"], nodes_117["varsity"], 5],
  [nodes_117["varsity"], nodes_117["mcirc"], 5],
  [nodes_117["mcirc"], nodes_117["stamsuhh_d"], 5]
]

start_point = nodes_117["stamsuhh_d"]
end_point = nodes_117["biofield"]

ob = Dijkstra.new(start_point, end_point, r)

puts "Cost = #{ob.cost}"
puts "Shortest Path from #{start_point} to #{end_point} = #{ob.shortest_path}"
