# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Log

    # Sets the current component for log info to the given value before executing the
    # given block and restores the previous component value after the block returns.
    # @param [String] comp component value for log info
    def self.for_component(comp, &block) end

  end

  class LogStderr

    # Creates a new LogStderr for the given file handle.
    # Possible values are 2 for `stderr` and 1 for `stdout`.
    # @param [Integer] fh file stream handle
    def initialize(fh = 2) end
  end

  class LogNull

    # Suspends logging before executing the given block and restarts logging when the block returns.
    def self.no_log(&block) end

  end

  class LogChain

    # Releases the redirection chain and restores the previous log instance as the active log target.
    # Traditionally in C++ applications would rely on the destructor to do this but that is not a really
    # predictable option in wxRuby since destruction only takes place after GC collection (which is not
    # exactly predictable) so wxRuby adds this method to better control restoration time if needed.
    # @return [void]
    def release; end

  end

end
