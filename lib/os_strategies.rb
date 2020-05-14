# frozen_string_literal: true

require_relative 'command_executor'

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

  class FailStrategy
    def initialize
      raise 'No strategy found for selected strategy'
    end
  end
  
  # Strategy for Alpine Linux.
  class LinuxStrategy
    def hostname
      execute('cat /etc/hostname')
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
      parse_process_list(multiline('top -n 1 -b'), split_tokens: 9) { |tokens| [tokens[0], tokens.last, hostname, tokens[4]] }
    end 
  end
  
  # Strategy for common MacOS.
  class MacStrategy
    def hostname
      execute('hostname')
    end
    
    ##
    # Must parse an entry as the one below.
    #
    # host:datacat user$ top -l 1 -o -mem -stats pid,command,cpu,mem
    # Processes: 259 total, 3 running, 256 sleeping, 1367 threads 
    # 2020/05/13 23:16:16
    # Load Avg: 2.74, 2.70, 2.69 
    # CPU usage: 20.30% user, 25.38% sys, 54.31% idle 
    # SharedLibs: 112M resident, 42M data, 8572K linkedit.
    # MemRegions: 113901 total, 708M resident, 28M private, 536M shared.
    # PhysMem: 4076M used (1324M wired), 19M unused.
    # VM: 1227G vsize, 1113M framework vsize, 30300682(0) swapins, 31327101(0) swapouts.
    # Networks: packets: 9824102/9508M in, 4756440/648M out.
    # Disks: 9076103/216G read, 5844462/181G written.
    # 
    # PID    COMMAND          %CPU MEM   
    # 0      kernel_task      0.0  595M+ 
    # 31585  Google Chrome He 0.0  144M+ 
    # 392    Google Chrome    0.0  95M+  
    # 24460  Code Helper (Ren 0.0  54M+ 
    ##
    def collect
      parse_process_list(multiline('top -l 1 -o -mem -stats pid,mem,command'), split_tokens: 3) { |tokens| [tokens.first, tokens.last, hostname, tokens[1]] }
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
