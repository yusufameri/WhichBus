module WhichBus
  class Node
    attr_accessor :name, :graph, :stop

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
