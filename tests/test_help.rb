# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

if Wx.has_feature?(:USE_HELP)


  class TestHelp < WxRuby::Test::GUITests


    class << self
      def hlp_initialised
        @hlp_initialized ||= false
      end
      def hlp_initialized=(init)
        @hlp_initialized = init
      end
    end

    def before_setup
      super
      unless self.class.hlp_initialised
        Wx::HelpProvider.set(Wx::HelpControllerHelpProvider.new)

        @hlp_controller = Wx::HelpController.new

        Wx::HelpProvider.get.set_help_controller(@hlp_controller)

        assert_true(@hlp_controller.init(File.join(__dir__, '..', 'samples', 'help', 'doc')))

        self.class.hlp_initialized = true
      end
    end

    def setup
      super
      @button = Wx::Button.new(frame_win, label: 'Button')
      @text = Wx::TextCtrl.new(frame_win, name: 'Text')
      @check = Wx::CheckBox.new(frame_win, label: 'Check Box')
      Wx::HelpProvider.get.add_help(frame_win, 'Frame help')
      Wx::HelpProvider.get.add_help(@button, 'Button help')
      Wx::HelpProvider.get.add_help(@text, 'Text help')
    end

    def teardown
      super
      @button.destroy
      @text.destroy
      @check.destroy
    end

    attr_reader :button, :text, :check

    def test_get_help
      assert_equal('Frame help', Wx::HelpProvider.get.get_help(frame_win))
      assert_equal('Button help', Wx::HelpProvider.get.get_help(button))
      assert_equal('Text help', Wx::HelpProvider.get.get_help(text))
      assert_empty(Wx::HelpProvider.get.get_help(check))
    end

    def test_show_help
      assert_true(Wx::HelpProvider.get.show_help(frame_win))
      assert_true(Wx::HelpProvider.get.show_help(button))
      assert_true(Wx::HelpProvider.get.show_help(text))
      assert_false(Wx::HelpProvider.get.show_help(check))
    end

    def test_remove_help
      assert_true(Wx::HelpProvider.get.show_help(button))
      Wx::HelpProvider.get.remove_help(button)
      assert_false(Wx::HelpProvider.get.show_help(button))
      assert_empty(Wx::HelpProvider.get.get_help(button))
    end

    def test_help_controller
      assert_true(Wx::HelpProvider.get.get_help_controller.display_contents)
      assert_true(Wx::HelpProvider.get.get_help_controller.quit)
      assert_true(Wx::HelpProvider.get.get_help_controller.display_section('Introduction'))
      assert_true(Wx::HelpProvider.get.get_help_controller.quit)
    end

  end

end
