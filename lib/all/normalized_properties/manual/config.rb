module NormalizedProperties
  module Manual
    class Config < PropertyConfig
      def initialize(owner, name, type, config)
        super owner, name,
          property_class: Manual.const_get(type),
          filter: ->(filter){ {name => filter} }
      end
    end
  end
end