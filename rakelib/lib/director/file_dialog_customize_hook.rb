# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class FileDialogCustomizeHook < Director

      def setup
        super
        spec.items << 'wxFileDialogCustomize'
        spec.gc_as_object 'wxFileDialogCustomizeHook'
        spec.gc_as_untracked 'wxFileDialogCustomize'
        spec.make_abstract 'wxFileDialogCustomize'
        spec.map_apply 'int n, const wxString* choices' => 'size_t n, const wxString *strings'
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxFileDialogCustomizeHook', 'wxRubyFileDialogCustomizeHook')
        spec.make_concrete('wxFileDialogCustomizeHook')
        # prevent director overload; custom impl handles this
        spec.no_proxy 'wxFileDialogCustomizeHook::AddCustomControls',
                      'wxFileDialogCustomizeHook::UpdateCustomControls',
                      'wxFileDialogCustomizeHook::TransferDataFromCustomControls'
        spec.add_header_code <<~__HEREDOC
          class wxRubyFileDialogCustomizeHook : public wxFileDialogCustomizeHook
          {
          public:
            wxRubyFileDialogCustomizeHook() : wxFileDialogCustomizeHook() {}
            ~wxRubyFileDialogCustomizeHook() {};

            // from virtual void wxFileDialogCustomizeHook::AddCustomControls
            virtual void AddCustomControls(wxFileDialogCustomize &customizer) override
            {
              VALUE obj0 = Qnil ;
              VALUE SWIGUNUSED result;
              
              obj0 = SWIG_NewPointerObj(SWIG_as_voidptr(&customizer), SWIGTYPE_p_wxFileDialogCustomize,  0 );
              VALUE self = SWIG_RubyInstanceFor(this);
              bool ex = false;
              result = wxRuby_Funcall(ex, self, rb_intern("add_custom_controls"), 1,obj0);
              if (ex)
              {
                wxRuby_PrintException(result);
              }
            }

            // from virtual void wxFileDialogCustomizeHook::UpdateCustomControls
            virtual void UpdateCustomControls() override
            {
              VALUE SWIGUNUSED result;
              
              if (!this->finished_)
              {
                VALUE self = SWIG_RubyInstanceFor(this);
                bool ex = false;
                result = wxRuby_Funcall(ex, self, rb_intern("update_custom_controls"), 0, NULL);
                if (ex)
                {
                  wxRuby_PrintException(result);
                }
              }
            }

            // from virtual void wxFileDialogCustomizeHook::TransferDataFromCustomControls
            virtual void TransferDataFromCustomControls() override
            {
              VALUE SWIGUNUSED result;
              
              
              if (!this->finished_)
              {
                this->finished_ = true;
                VALUE self = SWIG_RubyInstanceFor(this);
                bool ex = false;
                result = wxRuby_Funcall(ex, self, rb_intern("transfer_data_from_custom_controls"), 0, NULL);
                if (ex)
                {
                  wxRuby_PrintException(result);
                }
              }
            }
          
          private:
            bool finished_ {};
          };
          __HEREDOC
      end
    end # class FileDialogCustomizeHook

  end # class Director

end # module WXRuby3
