require 'uri'

module Azure
  class ModelURI
    @@klasses = Hash.new { ModelURI.new }

    def self.register(model_klass, uri_klass)
      @@klasses[model_klass] = uri_klass
    end

    def self.make(model_klass, &blk)
      register(model_klass, Class.new(ModelURI) do
        define_method(:uri, &blk)
      end)
    end

    def self.find(model)
      p [:model, model, :class, model.class]
      @@klasses[model.class].new(model)
    end

    class << self
      alias_method :[], :find
    end

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def uri
      fail NotImplementedError, "model: #{model.inspect}"
    end
  end

  def self.ModelURI(model)
    ModelURI[model].uri
  end
end
