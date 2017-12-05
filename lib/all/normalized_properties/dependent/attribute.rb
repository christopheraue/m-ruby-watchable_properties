module NormalizedProperties
  module Dependent
    class Attribute < Attribute
      def watch_sources
        @config.watch_sources @config.sources(@owner)
      end

      def value
        @owner.instance_exec @config.sources(@owner), &@config.value
      end

      def satisfies?(filter)
        filter = case filter
                 when Hash
                   Filter.new(:and, filter)
                 when Instance
                   Filter.new(:and, filter.to_filter)
                 else
                   filter
                 end
        filter = filter.and @config.value_filter.call(value) if @config.value_filter
        Filter.new(:and, @config.sources_filter.call(filter)).satisfied_by_instance? owner
      end
    end
  end
end