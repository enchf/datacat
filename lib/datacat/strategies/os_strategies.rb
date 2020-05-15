# frozen_string_literal: true

require 'datacat/command_executor'

require_relative 'fail_strategy'
require_relative 'linux_strategy'
require_relative 'mac_strategy'

module DataCat
  module OSStrategies
    PROCESS_DATA_FIELDS = %i[pid command instance memory_usage]
    PID = 'PID'

    module CommonRoutines
      def parse_process_list(lines, bottom_up: true, prefix: 'PID', split_tokens: 0)
        lines = lines.reverse if bottom_up

        lines
          .map(&:strip)
          .reject(&:empty?)
          .take_while { |line| !line.start_with?(prefix) }
          .map { |line| line.split(%r{\s+}, split_tokens) }
          .map { |tokens| PROCESS_DATA_FIELDS.zip(yield(tokens)).to_h }
      end
    end

    STRATEGIES = {
      'Linux' => LinuxStrategy,
      'Darwin' => MacStrategy  
    }.freeze

    def self.for(osname)
      STRATEGIES.fetch(osname, FailStrategy)
                .new
                .extend(CommandExecutor)
                .extend(CommonRoutines)
    end
  end
end
