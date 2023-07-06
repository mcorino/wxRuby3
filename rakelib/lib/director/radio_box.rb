###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class RadioBox < Window
      def setup
        spec.items << 'wxItemContainerImmutable'
        spec.fold_bases('wxRadioBox' => 'wxItemContainerImmutable')
        spec.override_inheritance_chain('wxRadioBox', %w[wxControl wxWindow wxEvtHandler wxObject])
        # ignore overloads hiding common Window method
        spec.ignore('wxRadioBox::Enable', 'wxRadioBox::Show')
        spec.add_extend_code 'wxRadioBox', <<~__HEREDOC
        // add custom method to reach common Window method overload
        bool EnableWindow(bool enable=true)
        {
          return $self->Enable(enable);
        }
        // add right method to enable/disable items
        bool EnableItem(unsigned int n, bool enable=true)
        {
          return $self->Enable(n, enable);
        }
        // add custom method to reach common Window method overload
        bool ShowWindow(bool show=true)
        {
          return $self->Show(show);
        }
        // add right method to show/hide items
        bool ShowItem(unsigned int n, bool show=true)
        {
          return $self->Show(n, show);
        }
        __HEREDOC
        # rename common method
        spec.rename_for_ruby('Enable' => 'wxRadioBox::EnableWindow')
        spec.rename_for_ruby('Show' => 'wxRadioBox::ShowWindow')
        super
      end
    end # class Window

  end # class Director

end # module WXRuby3
