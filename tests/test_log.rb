# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class LogTests < Test::Unit::TestCase

  class TestLogBase < Wx::Log

    def initialize
      super
      @logs = ::Array.new(Wx::LOG_Trace + 1)
      @logsInfo = ::Array.new(Wx::LOG_Trace + 1)
    end

    def get_log(level)
      @logs[level].to_s
    end

    def get_info(level)
      @logsInfo[level]
    end

    def clear
      @logs = ::Array.new(Wx::LOG_Trace + 1)
      @logsInfo = ::Array.new(Wx::LOG_Trace + 1)
    end

  end

  class TestLog < TestLogBase

    protected

    def do_log_record(level, msg, info)
      @logs[level] = msg
      # do not keep log info objects because these (and their state) are purely transient data
      # that can only be reliably accessed (or passed on) within this call scope
      @logsInfo[level] = { filename: info.filename, line: info.line, func: info.func, component: info.component }
    end

  end

  def setup
    super
    @logOld = Wx::Log.set_active_target(@log = TestLog.new)
    @logWasEnabled = Wx::Log.enable_logging
  end

  def cleanup
    Wx::Log.set_active_target(@logOld)
    Wx::Log.enable_logging(@logWasEnabled)
    super
  end

  def test_functions
    Wx.log_message("Message")
    assert_equal("Message", @log.get_log(Wx::LOG_Message))

    Wx.log_error("Error %d", 17)
    assert_equal("Error 17", @log.get_log(Wx::LOG_Error))

    Wx.log_debug("Debug")
    if Wx::WXWIDGETS_DEBUG_LEVEL > 0
      assert_equal( "Debug", @log.get_log(Wx::LOG_Debug))
    else
      assert_equal( "", @log.get_log(Wx::LOG_Debug))
    end
  end

  def test_null
    Wx::LogNull.no_log do
      Wx.log_warning("%s warning", "Not important")

      assert_equal("", @log.get_log(Wx::LOG_Warning))
      end

    Wx.log_warning("%s warning", "Important")
    assert_equal("Important warning", @log.get_log(Wx::LOG_Warning))
  end

  def test_component
    Wx.log_message('Message')
    assert_equal('wxapp',
                 @log.get_info(Wx::LOG_Message)[:component])

    # completely disable logging for this component
    Wx::Log.set_component_level('test/ignore', Wx::LOG_FatalError)

    # but enable it for one of its subcomponents
    Wx::Log.set_component_level('test/ignore/not', Wx::LOG_Max)

    Wx::Log.for_component('test/ignore') do
      # this shouldn't be output as this component is ignored
      Wx::log_error('Error')
      assert_equal('', @log.get_log(Wx::LOG_Error))

      # and so are its subcomponents
      Wx.log_error('Error', component: 'test/ignore/sub/subsub') # explicit component: overrules scoped setting
      assert_equal('', @log.get_log(Wx::LOG_Error))

      Wx.log_error('Error', component: 'test/ignore/not')
      assert_equal('Error', @log.get_log(Wx::LOG_Error))

      # restore the original component value
    end
  end

  def test_repetition_counting
    Wx::Log.set_repetition_counting(true)

    Wx.log_message('Message')
    assert_equal('Message', @log.get_log(Wx::LOG_Message))

    @log.clear
    Wx.log_message('Message')
    assert_equal('', @log.get_log(Wx::LOG_Message))
    Wx.log_message('Message')
    assert_equal('', @log.get_log(Wx::LOG_Message))

    Wx.log_info('Another message')
    if Wx.has_feature?(:USE_INTL)
      # don't what language may come out so just test if not empty anymore
      assert_not_empty(@log.get_log(Wx::LOG_Message))
    else
      assert_match(/The previous message.*repeated/, @log.get_log(Wx::LOG_Message))
    end
    assert_equal('Another message', @log.get_log(Wx::LOG_Info))

    Wx::Log.set_repetition_counting(false)
  end

  class MyBufferInterposer < Wx::LogInterposer

    def initialize
      super
      @buffer = []
    end

    attr_reader :buffer

    def do_log_text(msg)
      @buffer << msg
    end
    protected :do_log_text

  end

  def test_log_interposer
    buffer_log = MyBufferInterposer.new
    assert_empty(buffer_log.buffer)

    Wx.log_message('Message')
    assert_equal("Message", @log.get_log(Wx::LOG_Message))
    assert_equal(1, buffer_log.buffer.size)
    assert_match(/Message/, buffer_log.buffer.first)

    Wx.log_warning('Message')
    assert_equal("Message", @log.get_log(Wx::LOG_Warning))
    assert_equal(2, buffer_log.buffer.size)
    assert_match(/Message/, buffer_log.buffer.last)

  end

  def test_log_chain
    log_chain = Wx::LogChain.new(TestLog.new)
    assert_not_nil(log_chain.instance_variable_get('@new_log'))
    assert_kind_of(TestLog, log_chain.instance_variable_get('@new_log'))
    log_chain = nil # GC collection should still be prevented
    GC.start
    log_chain = Wx::Log.get_active_target
    assert_kind_of(Wx::LogChain, log_chain)
    assert_not_nil(log_chain.instance_variable_get('@new_log'))
    assert_kind_of(TestLog, log_chain.instance_variable_get('@new_log'))
    log_chain = nil # GC collection should still be prevented
    GC.start
    Wx.log_message('Message')
    log_chain = Wx::Log.get_active_target
    new_log = log_chain.instance_variable_get('@new_log')
    assert_equal('Message', @log.get_log(Wx::LOG_Message))
    assert_equal('Message', new_log.get_log(Wx::LOG_Message))
    log_chain = new_log = nil
    GC.start
    Wx.log_warning('Message 2')
    log_chain = Wx::Log.get_active_target
    new_log = log_chain.instance_variable_get('@new_log')
    assert_equal('Message 2', @log.get_log(Wx::LOG_Warning))
    assert_equal('Message 2', new_log.get_log(Wx::LOG_Warning))
    log_chain.release
    Wx.log_message('Message 3')
    assert_equal('Message 3', @log.get_log(Wx::LOG_Message))
    assert_not_equal('Message 3', new_log.get_log(Wx::LOG_Message))
    log_chain = new_log = nil
    GC.start
  end

  def test_interposer_chain
    log_chain = MyBufferInterposer.new
    assert_false(log_chain.instance_variable_defined?('@new_log'))
    log_chain = nil # GC collection should still be prevented
    GC.start
    log_chain = Wx::Log.get_active_target
    assert_kind_of(MyBufferInterposer, log_chain)
    log_chain = nil # GC collection should still be prevented
    GC.start
    Wx.log_message('Message')
    log_chain = Wx::Log.get_active_target
    assert_equal('Message', @log.get_log(Wx::LOG_Message))
    assert_equal(1, log_chain.buffer.size)
    assert_match(/Message/, log_chain.buffer.first)
    log_chain = nil
    GC.start
    Wx.log_message('Message 2')
    log_chain = Wx::Log.get_active_target
    assert_equal('Message 2', @log.get_log(Wx::LOG_Message))
    assert_equal(2, log_chain.buffer.size)
    assert_match(/Message 2/, log_chain.buffer.last)
    Wx::Log.set_active_target(log_chain.get_old_log)
    log_chain = nil
    GC.start
    Wx.log_message('Message 3')
    assert_equal('Message 3', @log.get_log(Wx::LOG_Message))
  end

end
