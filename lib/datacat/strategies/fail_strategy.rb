# frozen_string_literal: true

module DataCat
  module OSStrategies
    class FailStrategy
      def initialize
        raise 'No strategy found for selected strategy'
      end
    end
  end   
end
