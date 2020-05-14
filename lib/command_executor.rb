# frozen_string_literal: true

class CommandExecutor
    class << self
        def execute(command)
            `#{command}`.strip
        end

        def multiline(command)
            execute(command).split("\n").map(&:strip)
        end
    end
end
