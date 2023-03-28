###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class VListBox < Window

      def setup
        super
        spec.override_inheritance_chain('wxVListBox', %w[wxVScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
        spec.make_abstract 'wxVListBox'
        # provide base implementations for OnDrawItem and OnMeasureItem
        spec.add_header_code <<~__HEREDOC
          // Custom subclass implementation. 
          class wxRubyVListBox : public wxVListBox
          {
          public:
            wxRubyVListBox() 
              : wxVListBox () {}
            wxRubyVListBox(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxVListBoxNameStr)
              : wxVListBox(parent, id, pos, size, style, name) {}
          protected:
            virtual void OnDrawItem(wxDC&, const wxRect&, size_t) const
            {
              rb_raise(rb_eNoMethodError, "Not implemented");
            }
            virtual wxCoord OnMeasureItem(size_t) const
            {
              rb_raise(rb_eNoMethodError, "Not implemented");
            }
          };
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxVListBox', 'wxRubyVListBox')
      end
    end # class VListBox

  end # class Director

end # module WXRuby3
