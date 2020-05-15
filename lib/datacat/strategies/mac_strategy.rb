# frozen_string_literal: true

module DataCat
  module OSStrategies
    # Strategy for common MacOS.
    class MacStrategy
      SIZES = {
        'B' => 1,
        'K' => 1_000,
        'M' => 1_000_000,
        'G' => 1_000_000_000
      }.freeze

      MEMORY_FORMAT = /([0-9]+)([A-Z]).*/

      def hostname
        @hostname ||= execute('hostname')
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
      # PID    MEM    COMMAND     
      # 0      595M+  kernel_task
      # 31585  144M+  Google Chrome He
      # 392    95M+   Google Chrome 
      # 24460  54M+   Code Helper (Ren 
      ##
      def collect
        parse_process_list(multiline('top -l 1 -o mem -stats pid,mem,command'), split_tokens: 3) do |tokens| 
          [tokens.first, tokens.last, hostname, plain_memory_value(tokens[1])]
        end
      end

      private

      def plain_memory_value(value)
        memory, multiplier = value.match(MEMORY_FORMAT).captures
        memory.to_i * SIZES[multiplier]
      end
    end
  end
end
