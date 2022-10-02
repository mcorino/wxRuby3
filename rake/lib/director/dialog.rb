#--------------------------------------------------------------------
# @file    dialog.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Dialog < TopLevelWindow

      def setup
        super
        case spec.module_name
        when 'wxDialog'
          spec.ignore('wxDialog::GetContentWindow')
          spec.swig_import('include/defs.h')
        when 'wxFontDialog'
          spec.add_swig_runtime_code '%apply SWIGTYPE *DISOWN { wxFontData* data };'
        when 'wxFileDialog'
          spec.add_swig_runtime_code <<~__HEREDOC
            %typemap(in,numinputs=0) wxArrayString &(wxArrayString sel)
            {
              $1 = &sel;
            }
            
            %typemap(argout) wxArrayString &{
              $result = rb_ary_new();
              for (size_t i = 0; i < $1->GetCount(); i++)
                rb_ary_push($result, WXSTR_TO_RSTR( (*$1)[i] ) );
            }
            __HEREDOC
          spec.ignore 'wxFileDialog::SetExtraControlCreator'
        end
      end
    end # class Dialog

  end # class Director

end # module WXRuby3
