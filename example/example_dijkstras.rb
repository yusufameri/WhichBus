require_relative "../lib/which_bus.rb"
require "pp"
require "uri"
require 'json'
require "net/HTTP"
require 'date'

# constants
uri = URI.parse("HTTP://restbus.info")
HTTP = Net::HTTP.new(uri.host, uri.port)
BASE_URI = "/api/agencies/umd"

@api = WhichBus::APIMethods.new


stops_116 = @api.get_stops_for_route(116) # bus stops in order of 116 Purple
stops_117 = @api.get_stops_for_route(117) # bus stops in order of 117 Blue
nodes_116 = []
nodes_117 = []


# make the graph
graph = WhichBus::Graph.new

# create nodes from bus stop ids and add them to the graph
def create_nodes_from(stops)
  nodes = []
  stops.each do |stop|
    nodes << WhichBus::Node.new("#{stop[1].title}", stop[1])
  end
  nodes
end

# nodes_117 = create_nodes_from(stops_117)
nodes_116 = create_nodes_from(stops_116)

# adds the nodes to the graph
def add_nodes_to_graph(graph, nodes)
  nodes.each do |node|
    graph.add_node(node)
  end
end

# add_nodes_to_graph(graph, nodes_117)
add_nodes_to_graph(graph, nodes_116)

# connect all the nodes for a particular bus to its normal schedualed path
def connect_nodes(graph, nodes, route_id)
  # connect the nodes on the graph to each other, sequentially
  nodes[0..-1].each_with_index do |node, index|
    node.route_id = route_id
    # connect the last node to the first node
    if index == nodes.size - 1
      node_1 = node
      node_2 = nodes[0]
      time_n_1 = @api.get_epoch_time(route_id, node_1.stop.id)
      time_n_2 = @api.get_epoch_time(route_id, node_2.stop.id)
      net_time = (time_n_2 - time_n_1).abs
      graph.add_edge(node_1, node_2 , net_time)
    else # connect the current node to the next node
      node_1 = node
      node_2 = nodes[index + 1]
      time_n_1 = @api.get_epoch_time(route_id, node_1.stop.id)
      time_n_2 = @api.get_epoch_time(route_id, node_2.stop.id)
      net_time = (time_n_2 - time_n_1).abs
      graph.add_edge(node_1, node_2 , net_time)
    end
  end
end

# connect_nodes(graph, nodes_117, 117)
connect_nodes(graph, nodes_116, 116)

# returns the index that the node with stopid is in the nodes array
def index_of_stopid(stopid, nodes)
  nodes.find_index do |node|
    node.stop.id == stopid
  end
end

# returns the node object based on stopid param
def get_node_by_stopid(nodes, stopid)
  nodes[index_of_stopid(stopid, nodes)]
end

# prints the shortest path on the graph given a graph
def print_shortest_path(graph, nodes, source_stopid, destination_stopid)
  source_node = get_node_by_stopid(nodes, source_stopid)
  destination_node = get_node_by_stopid(nodes, destination_stopid)

  dijkstra = WhichBus::Dijkstra.new(graph, source_node)
  shortest_path = dijkstra.shortest_path_to(destination_node)

  epochTime = dijkstra.distance.first[1] # total cost of time
  time = Time.at(Time.now - epochTime).min
  source_node_title = get_node_by_stopid(nodes, source_stopid).name
  destination_node_title = get_node_by_stopid(nodes, destination_stopid).name


  puts "It should take about #{time} min to get from #{source_node_title} to #{destination_node_title}"
  puts "Here is the path you need to take:"
  shortest_path.each_with_index do |bus_stop, index|
    puts "#{index + 1}: #{bus_stop} with bus: #{bus_stop.route_id}"
  end
  return shortest_path
end

# all_nodes = nodes_117 + nodes_116

print_shortest_path(graph, nodes_116, "hoff", "biofield")
