# frozen_string_literal: true

module DataCat
  module CommandExecutor
    def execute(command)
      `#{command}`.strip
    end

    def multiline(command)
      execute(command).split("\n").map(&:strip)
    end
  end
end
