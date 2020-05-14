# frozen_string_literal: true

require_relative 'command_executor'

module OSStrategies
  PROCESS_DATA_FIELDS = %i[pid command instance memory_usage]
  PID = 'PID'

  class FailStrategy
    def initialize
      raise 'Invalid strategy selection'
    end
  end
  
  # Strategy for Alpine Linux.
  class LinuxStrategy
    def hostname
      CommandExecutor.execute('cat /etc/hostname')
    end

    ##
    # Must parse an entry as the one below.
    #
    # / # top -n 1 -b
    # Mem: 974216K used, 1072916K free, 644K shrd, 54140K buff, 568812K cached
    # CPU:   0% usr   0% sys   0% nic 100% idle   0% io   0% irq   0% sirq
    # Load average: 0.00 0.01 0.00 2/507 45
    #   PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
    #     1     0 root     S     1644   0%   0   0% /bin/ash
    #    45     1 root     R     1576   0%   0   0% top -n 1 -b
    ##
    def collect
      CommandExecutor.multiline('top -n 1 -b')
                     .reverse
                     .map(&:strip)
                     .reject(&:empty?)
                     .take_while { |line| !line.start_with?('PID') }
                     .map { |line| line.split(%r{\s+}, 9) }
                     .map { |tokens| PROCESS_DATA_FIELDS.zip([tokens[0], tokens.last, hostname, tokens[4]]).to_h }
    end 
  end
  
  # Strategy for common MacOS.
  class MacStrategy
    def hostname
      CommandExecutor.execute('hostname')
    end
    
    def collect
      CommandExecutor.multiline('top -l 1 -o -mem -stats pid,command,mem')
    end
  end

  STRATEGIES = {
   'Linux' => LinuxStrategy,
   'Darwin' => MacStrategy  
  }.freeze

  def self.for(osname)
    STRATEGIES.fetch(osname, FailStrategy).new
  end
end
