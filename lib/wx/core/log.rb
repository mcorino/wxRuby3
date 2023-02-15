
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
    end
  end

  def self.log_debug(_fmt, *_args)
    if Wx.has_feature?(:USE_LOG_DEBUG) && Wx::Log.is_level_enabled(LogLevelValues::LOG_Debug, 'wx')
      Wx.log_generic(LogLevelValues::LOG_Debug, _fmt, *_args)
    end
    nil
  end

end
