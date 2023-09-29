# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class DialogTests < Test::Unit::TestCase

  class TestDialog < Wx::Dialog
    def initialize
      super()
    end
  end

  def test_dialog_inheritance
    dlg = TestDialog.new
    assert_kind_of(Wx::Dialog, dlg)
    assert_kind_of(Wx::Window, dlg)
  end
end
