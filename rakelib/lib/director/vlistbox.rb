# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class VListBox < Window

      def setup
        super
        spec.override_inheritance_chain('wxVListBox', [{ 'wxVScrolledWindow' => 'wxHVScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
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
        # make sure protected methods are included
        spec.regard 'wxVListBox::OnDrawItem',
                    'wxVListBox::OnMeasureItem',
                    'wxVListBox::OnDrawSeparator',
                    'wxVListBox::OnDrawBackground'
        # ignore these very un-Ruby methods
        spec.ignore 'wxVListBox::GetFirstSelected',
                    'wxVListBox::GetNextSelected'
        # add rubified API (finish in pure Ruby)
        spec.add_extend_code 'wxVListBox', <<~__HEREDOC
          VALUE each_selected()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              unsigned long cookie;
              int sel = $self->GetFirstSelected(cookie);
              for (; sel != wxNOT_FOUND ;sel = $self->GetNextSelected(cookie))
              {
                rc = rb_yield (INT2NUM(sel));
              }
            }
            return rc;  
          }
          __HEREDOC
      end
    end # class VListBox

  end # class Director

end # module WXRuby3
