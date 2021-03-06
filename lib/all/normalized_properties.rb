module NormalizedProperties
  # Usage: `extend NormalizedProperties`
  #
  # The instances of the classes extended with this module get the methods
  # defined in the Instance namespace. Usually, instance and class methods
  # are organized the other way around:
  #
  #   module NormalizedProperties
  #     module ClassMethods
  #       # Definition of class methods
  #     end
  #
  #     # Definition of instance Methods
  #   end
  #
  #   class Model
  #     include NormalizedProperties
  #   end
  #
  # The exact opposite is done here, because including a module also alters
  # constant lookup inside the class it is included into. Example: An
  # Extensions to NormalizedProperties might define
  #
  #   module NormalizedProperties::WorldObject
  #     # Extension
  #   end
  #
  # After `include NormalizedProperties` a simple `WorldObject` in `Model`
  # references `NormalizedProperties::WorldObject` instead the top level
  # `::WorldObject`. To avoid this `extend NormalizedProperties` is used. This
  # does not alter the constant lookup in unexpected ways.

  module Instance
    def property(name)
      @properties ||= {}
      @properties[name] ||= self.class.property_config(name).to_property_for self
    end

    def to_filter
      itself
    end

    def satisfies?(filter)
      case filter
      when Filter, Set::Filter
        filter.satisfied_by? self
      when Hash
        filter.all? do |prop_name, prop_filter|
          property(prop_name).satisfies? prop_filter
        end
      when true
        true
      else # Instance
        filter === self
      end
    end
  end

  def self.extended(klass)
    klass.instance_variable_set :@property_configs, {}
    klass.__send__ :include, Instance
  end

  def inherited(klass)
    NormalizedProperties.extended klass
    super
  end

  def normalized_attribute(name, config)
    type = config.delete(:type){ config.fetch :type }
    namespace = if NormalizedProperties.const_defined? type
                  NormalizedProperties.const_get type
                else
                  raise Error, "unknown property type #{type.inspect}"
                end

    config_class = (namespace.const_defined? :AttributeConfig) ? namespace::AttributeConfig : AttributeConfig
    @property_configs[name] = config_class.new self, name, namespace, config
  end

  def normalized_set(name, config)
    type = config.delete(:type){ config.fetch :type }
    namespace = if NormalizedProperties.const_defined? type
                  NormalizedProperties.const_get type
                else
                  raise Error, "unknown property type #{type.inspect}"
                end

    config_class = (namespace.const_defined? :SetConfig) ? namespace::SetConfig : SetConfig
    @property_configs[name] = config_class.new self, name, namespace, config
  end

  def owns_property?(name)
    @property_configs.key? name or if superclass.singleton_class.include? NormalizedProperties
                                     superclass.owns_property? name
                                   else
                                     false
                                   end
  end

  def property_config(prop_name)
    config = (@property_configs[prop_name] or if superclass.singleton_class.include? NormalizedProperties
                                                superclass.property_config prop_name
                                              end)
    config or raise Error, "property #{name}##{prop_name} does not exist"
  end
end

NP = NormalizedProperties