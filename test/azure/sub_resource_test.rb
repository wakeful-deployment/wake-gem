require "helper"
require "wake/azure/sub_resource"

describe Azure::SubResource do
  let(:klass) do
    Class.new do
      include Azure::SubResource
      parent :other_thing
    end
  end

  let(:thing) do
    Class.new do
      def location; "somewhere" end
    end.new
  end

  it "gets its location from its parent" do
    k = klass.new name: "foo", other_thing: thing
    assert_equal "somewhere", k.location
  end

  it "requires a name" do
    k = klass.new other_thing: thing
    assert k.invalid?
  end
end
