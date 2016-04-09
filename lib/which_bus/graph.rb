module WhichBus
  class Graph
    attr_accessor :nodes
    attr_accessor :edges

    def initialize
      @nodes = []
      @edges = []
    end

    def add_node(node)
      nodes << node
      node.graph = self
    end

    def add_edge(from, to, weight, route_id)
      edges << Edge.new(from, to, weight, route_id)
    end
  end
end
