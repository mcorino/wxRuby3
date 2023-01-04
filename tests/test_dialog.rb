require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

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

class TestApp < Wx::App
  def on_init
    Test::Unit::UI::Console::TestRunner.run(DialogTests)
    false
  end
end

app = TestApp.new
app.run
