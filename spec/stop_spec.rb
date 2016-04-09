require "spec_helper"
module WhichBus
  describe Stop do
    context "#initialize" do
      it "does not raise error when initialized correctly" do
        expect{Stop.new(12345, 543210, "laplat","LaPlata Hall")}.to_not raise_error
      end
    end
  end
end
