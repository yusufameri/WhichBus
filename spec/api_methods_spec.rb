require "spec_helper"
module WhichBus
  describe APIMethods do
    context "#initialize" do
      it "correctly initializes with the restbus api" do
        expect(true).to eql true
      end
    end

    context "#get_stops" do
      it "returns a non empty hash for 116 bus stops" do
      end
    end

    context "#get_routes" do
      it "returns all the routes" do
        api = APIMethods.new
        expect(api.get_routes.size).to eql(28)
      end
    end

    context "#get_all_stops" do
      api = APIMethods.new
      it "does not raise error" do
        expect{api.get_all_stops}.to_not raise_error
      end
      it "has many stops" do
        api.get_all_stops.size
      end
    end
    context "#save_stops" do
      api = APIMethods.new
      it "saves the stops" do
        api.save_stops
      end
    end
    context "#stops_array" do
      api = APIMethods.new
      it "has 464 stops" do
        expect(api.stops_array.size).to eql(464)
      end
      it "contains laplata hall information" do
        stops = api.stops_hash
        expect(stops["laplat"]).to be
        expect(stops["laplat"].lat).to eql(38.992218)
        expect(stops["laplat"].lon).to eql(-76.94563)
        expect(stops["laplat"].id).to eql("laplat")
        expect(stops["laplat"].title).to eql("La Plata Hall")
      end
    end
    context "#get_closest_stop" do
      api = APIMethods.new
      it "returns laplat stop object when same exact coordinate" do
        coordinate = { lat:38.992218, lon: -76.94563 }
        expect(api.get_closest_stop(coordinate).id).to eql("laplat")
      end
    end
    context "#get_routes_on_bus_stop" do
      api = APIMethods.new
      it "returns the routes at laplat" do
        expect(api.get_routes_on_bus_stop("laplat")).to eql(["115","122","137"])
      end
    end
    context "#common_buses" do
      api = APIMethods.new
      it "returns an array of routes that is not empty for two stops that share routes common" do
        expect(api.common_buses("msqua","cpmetro_d")).to eql(["109"])
        puts api.common_buses("msqua","cpmetro_d")
      end
    end
    context "#get_epoch_times" do
      api = APIMethods.new
      it "has epoch times" do
          expect(api.get_epoch_times(114, "stamsuhh_d")).to be
      end
      it "returns nil if the bus is not running atm" do
        expect(api.get_epoch_times(115, "laplat")).to be_nil
      end
    end
    context "#estimated_arrival_time" do
      api = APIMethods.new
      it "estimates correct time when stop comes after" do
        api.estimated_arrival_time(114, "stamsuhh_d", "rossknox_d")
      end
      it "estimates correct time when stop comes before" do
        api.estimated_arrival_time(114, "rossknox_d", "stamsuhh_d")
      end
    end
    context "#which_bus" do
      api = APIMethods.new
      it "gives the best bus to take" do
        # start_coordinate = {lat: 38.987872, lon: -76.947269} # lot1
        # hoff_coordinate = {lat: 38.987787, lon:-76.944840} # hoff
        stamp_coordinate = {lat: 38.9876098, lon: -76.9439438} # stamsu_m
        # wicomio_coordinate = {lat: 38.9841221, lon: -76.9452052} # wicomio_coordinate
        metro_station = {  lat: 38.9781498, lon: -76.9275778}
        msqua = {lat: 38.9707573, lon: -76.9229913}
        # baltritc = {lat: 38.985129, lon: -76.9371704}
        # end_coordinate = {lat: 38.992646, lon: -76.854949} # nasa
        current_location = {lat: 38.992599, lon: -76.938824} # current location
        api.which_bus(msqua, metro_station)
      end
    end
  end
end
