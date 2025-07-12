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
        if Config.instance.wx_version_check('3.3.0') > 0
          spec.override_inheritance_chain('wxVListBox', [{ 'wxVScrolledWindow' => 'wxVScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        else
          spec.override_inheritance_chain('wxVListBox', [{ 'wxVScrolledWindow' => 'wxHScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        end
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
            }
            virtual wxCoord OnMeasureItem(size_t) const
            {
              return {};
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
        # optimize; no need for these virtuals here
        spec.no_proxy 'wxVListBox::OnGetRowHeight',
                      'wxVListBox::OnGetRowsHeightHint'
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
