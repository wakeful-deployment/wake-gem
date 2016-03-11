require "helper"
require "wake/azure/model"

describe Azure::Model do
  let(:klass) do
    Class.new do
      include Azure::Model

      parent   :other_thing
      required :id
      optional :foo
      optional :location, default: ->{ parent.location }
    end
  end

  let(:simpler_klass) do
    Class.new do
      include Azure::Model
      required :id
    end
  end

  let(:thing) do
    Class.new do
      include Azure::Model
      def location; "somewhere" end
    end.new
  end

  describe "klass" do
    it "works" do
      k = klass.new(id: 1, other_thing: thing)
      assert_equal 1, k.id
      assert_nil k.foo
      assert k.valid?
    end

    it "requires a parent" do
      assert_raises Azure::Model::MissingParent do
        klass.new id: 1 # without other_thing
      end
    end

    it "defaults to its parent's location" do
      k = klass.new id: 1, other_thing: thing
      assert_equal "somewhere", k.location
    end

    it "is not valid unless its parent is valid" do
      thing.stub(:valid?, false) do
        k = klass.new id: 1, parent: thing
        assert k.invalid?
      end
    end
  end

  describe "simpler klass" do
    it "works" do
      k = simpler_klass.new id: 1
      assert k.valid?
    end

    it "is invalid without an id" do
      k = simpler_klass.new
      assert k.invalid?
    end

    it "does not know it's parent" do
      assert_raises Azure::Model::MissingParent do
        simpler_klass.new.parent
      end
    end
  end
end
