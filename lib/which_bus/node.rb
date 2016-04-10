module WhichBus
  class Node
    attr_accessor :name, :graph, :stop, :route_id

    # we add the instance variable route_id so upon printing, we know which bus
    # route_id is being "crossed" at this particular node
    def initialize(name, stop)
      @name = name
      @stop = stop
    end

    def adjacent_edges
      graph.edges.select{|e| e.from == self}
    end

    def to_s
      @name
    end
  end
end
