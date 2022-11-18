#--------------------------------------------------------------------
# @file    radio_box.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class RadioBox < Window
      def setup
        spec.items << 'wxItemContainerImmutable'
        spec.fold_bases('wxRadioBox' => 'wxItemContainerImmutable')
        spec.ignore_bases('wxRadioBox' => 'wxItemContainerImmutable')
        # ignore overload hiding common Window method
        spec.ignore('wxRadioBox::Enable')
        spec.add_extend_code 'wxRadioBox', <<~__HEREDOC
        // add custom method to reach common Window method
        bool EnableWindow(bool enable=true)
        {
          return $self->wxWindow::Enable(enable);
        }
        // add right method to enable/disable items
        bool EnableItem(unsigned int n, bool enable=true)
        {
          return $self->Enable(enable);
        }
        __HEREDOC
        # rename common method
        spec.rename_for_ruby('Enable' => 'wxRadioBox::EnableWindow')
        super
      end
    end # class Window

  end # class Director

end # module WXRuby3
