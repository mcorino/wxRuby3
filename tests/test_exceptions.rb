# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxrb_test'
require 'plat4m'
require 'open3'

class DirectorExceptionTests < Minitest::Test

  # Path to the currently running Ruby program
  RUBY = ENV["RUBY"] || File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]).
    sub(/.*\s.*/m, '"\&"')

  INC_DIR = File.realpath(File.join(__dir__, '..', 'lib'))

  OPTS = {
    :err => (Plat4m.current.windows? ? 'NULL' : '/dev/null'), :out => (Plat4m.current.windows? ? 'NULL' : '/dev/null'),
  }

  def test_invalid_overload_type
    assert_false(Kernel.system(RUBY, '-I', INC_DIR, File.join(__dir__, 'lib/overload_type_exception_test.rb'), **OPTS))
    assert_equal(126, $?.exitstatus)
  end

  def test_leaked_exception_in_overload
    assert_false(Kernel.system(RUBY, '-I', INC_DIR, File.join(__dir__, 'lib/leaked_overload_exception_test.rb'), **OPTS))
    assert_equal(127, $?.exitstatus)
  end

  def test_leaked_process_event_handling_exception
    assert_false(Kernel.system(RUBY, '-I', INC_DIR, File.join(__dir__, 'lib/leaked_process_event_exception_test.rb'), **OPTS))
    assert_equal(1, $?.exitstatus)
  end

  def test_leaked_queued_event_handling_exception
    assert_false(Kernel.system(RUBY, '-I', INC_DIR, File.join(__dir__, 'lib/leaked_queued_event_exception_test.rb'), **OPTS))
    assert_equal(1, $?.exitstatus)
  end

end
