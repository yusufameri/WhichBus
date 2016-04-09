module WhichBus
  class Edge
    attr_accessor :from, :to, :weight

    def initialize(from, to, weight, route_id)
      @from, @to, @weight, @route_id = from, to, weight, route_id
    end

    def <=>(other)
      self.weight <=> other.weight
    end

    def to_s
      "#{from.to_s} => #{to.to_s} with weight #{weight} and on route: #{route_id}"
    end
  end
end
