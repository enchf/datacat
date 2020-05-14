# frozen_string_literal: true

require_relative 'command_executor'

module OSStrategies
  class FailStrategy
    def initialize
      raise 'Invalid strategy selection'
    end
  end
  
  class LinuxStrategy
    def hostname
      CommandExecutor.execute('cat /etc/hostname')
    end
    
    def collect
      CommandExecutor.multiline('top -n 1 -b')
    end
  end
  
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
