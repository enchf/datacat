# frozen_string_literal: true

module DataCat
  module OSStrategies
    # Strategy for Alpine Linux.
    class LinuxStrategy
      def hostname
        @hostname ||= execute('cat /etc/hostname')
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
        parse_process_list(multiline('top -n 1 -b'), split_tokens: 9) do |tokens| 
          [tokens[0], tokens.last, hostname, tokens[4]]
        end
      end 
    end
  end   
end
  