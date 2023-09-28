# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class Log
    class << self
      alias :active_target= :set_active_target
      alias :active_target :get_active_target
      alias :log_level :get_log_level
      alias :log_level= :set_log_level
      alias :enabled? :is_enabled
      alias :repetition_counting :get_repetition_counting
      alias :repetition_counting= :set_repetition_counting
      alias :timestamp :get_timestamp
      alias :timestamp= :set_timestamp
      alias :verbose :get_verbose
      alias :verbose= :set_verbose

      def set_component(comp)
        @component = comp ? comp.to_s : comp
      end
      private :set_component

      def component
        @component
      end

      def for_component(comp, &block)
        old_comp = component
        set_component(comp)
        begin
          block.call if block_given?
        ensure
          set_component(old_comp)
        end
      end

    end

  end

  class << self

    def setup_log_info(fmt, args, filename, line, func, component)
      # as wxRuby apps will ever only log from the main thread the only reason why
      # log info data may be retained beyond the execution scope of the current
      # log action is because of log repetition counting which will retain the
      # first log info instance of a repeating message sequence

      # format message
      msg = fmt % args
      log_info = {
        filename: if filename
                    filename.to_s
                  else
                    filename
                  end,
        line: line,
        func: if func
                func.to_s
              else
                func
              end,
        component: if component
                     component.to_s
                   else
                     Log.component
                   end
      }
      if Wx::Log.get_repetition_counting && @last_msg != msg
        # refresh cache
        @last_msg = msg
        @last_info = log_info
      end
      [msg, log_info]
    end
    private :setup_log_info

    wx_log_generic = self.instance_method :log_generic
    define_method :log_generic do |lvl, fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_generic.bind(self).call(lvl, *setup_log_info(fmt, args, filename, line, func, component))
    end

    wx_log_info = self.instance_method :log_info
    define_method :log_info do |fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_info.bind(self).call(*setup_log_info(fmt, args, filename, line, func, component))
    end

    wx_log_verbose = self.instance_method :log_verbose
    define_method :log_verbose do |fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_verbose.bind(self).call(*setup_log_info(fmt, args, filename, line, func, component))
    end

    wx_log_message = self.instance_method :log_message
    define_method :log_message do |fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_message.bind(self).call(*setup_log_info(fmt, args, filename, line, func, component))
    end

    wx_log_warning = self.instance_method :log_warning
    define_method :log_warning do |fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_warning.bind(self).call(*setup_log_info(fmt, args, filename, line, func, component))
    end

    wx_log_error = self.instance_method :log_error
    define_method :log_error do |fmt, *args, filename: nil, line: 0, func: nil, component: nil|
      wx_log_error.bind(self).call(*setup_log_info(fmt, args, filename, line, func, component))
    end

  end

end
