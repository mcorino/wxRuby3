#--------------------------------------------------------------------
# @file    dialog.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './top_level_window'

module WXRuby3

  class Director

    class Dialog < TopLevelWindow

      def setup
        super
        case spec.module_name
        when 'wxDialog'
          spec.ignore('wxDialog::GetContentWindow',
                      'wxDialog::GetToolBar') # seemingly removed from MSW
          spec.swig_import('swig/classes/include/wxDefs.h')
        when 'wxFontDialog'
          spec.add_swig_code '%apply SWIGTYPE *DISOWN { wxFontData* data };'
        when 'wxFileDialog'
          spec.add_swig_code <<~__HEREDOC
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
          if Config.instance.wx_version >= '3.2.1'
            # doc does not seem to match actual header code so just ignore for now
            spec.ignore('wxFileDialog::AddShortcut')
          end
        when 'wxPropertySheetDialog'
          spec.ignore 'wxPropertySheetDialog::GetContentWindow'
          # In Ruby a derived class with customized '#initialize' is far easier
          spec.ignore 'wxPropertySheetDialog::CreateBookCtrl'
          # Needs special handling to ensure the return value is cast to the
          # correct book class, not the generic abstract parent class
          # wxBookCtrlBase
          spec.ignore('wxPropertySheetDialog::GetBookCtrl', ignore_doc: false) # keep doc
          spec.add_extend_code 'wxPropertySheetDialog', <<~__HEREDOC
            VALUE get_book_ctrl() {
              wxBookCtrlBase* book = $self->GetBookCtrl();
              return wxRuby_WrapWxObjectInRuby( (wxObject*)book) ;
            }
            __HEREDOC
        when 'wxFindReplaceDialog'
          spec.ignore 'wxFindReplaceDialog::wxFindReplaceDialog()'
          spec.add_swig_code '%apply SWIGTYPE *DISOWN { wxFindReplaceData* data };'
          spec.do_not_generate(:variables, :enums)
        when 'wxColourDialog'
        when 'wxTextEntryDialog'
        when 'wxSingleChoiceDialog'
          # unnneeded and unwanted for Ruby
          spec.ignore 'wxSingleChoiceDialog::wxSingleChoiceDialog(wxWindow *,const wxString &,const wxString &,int,const wxString *,void **,long,const wxPoint &)'
          spec.add_swig_code <<~__HEREDOC
            // Wx's SingleChoiceDialog offers the possibility of attaching client
            // data to each choice. However this would need memory management, and a
            // pure ruby implementation is trivial and likely to be more convenient
            // on a per-case basis.
            %typemap("in", numinputs=0) char** clientData "$1 = (char **)NULL;"
            __HEREDOC
          spec.do_not_generate(:functions)
        when 'wxMultiChoiceDialog'
          # unnneeded and unwanted for Ruby
          spec.ignore 'wxMultiChoiceDialog::wxMultiChoiceDialog(wxWindow *,const wxString &,const wxString &,int,const wxString *,long,const wxPoint &)'
          spec.add_swig_code <<~__HEREDOC
            // Wx's MultiChoiceDialog offers the possibility of attaching client
            // data to each choice. However this would need memory management, and a
            // pure ruby implementation is trivial and likely to be more convenient
            // on a per-case basis.
            %typemap("in", numinputs=0) char** clientData "$1 = (char **)NULL;"
          __HEREDOC
          spec.do_not_generate(:functions, :enums, :defines)
        when 'wxDirDialog'
        when 'wxProgressDialog'
          # These two have problematic arguments; they accept a bool pointer
          # which will be set to true if "skip" was pressed since the last
          # update. Dealt with below.
          spec.make_concrete 'wxProgressDialog'
          spec.items << 'wxGenericProgressDialog'
          spec.fold_bases('wxProgressDialog' => 'wxGenericProgressDialog')
          spec.ignore(%w[wxGenericProgressDialog::Pulse wxGenericProgressDialog::Update], ignore_doc: false) # keep docs
          # TODO : add docs for Ruby specials
          spec.add_extend_code 'wxProgressDialog', <<~__HEREDOC
            // In wxRuby there are two versions of each of these methods, the
            // standard one which returns just true/false depending on whether it
            // has been aborted, and a special one which returns a pair of values,
            // true/false for "aborted" and then true/false for "skipped"
            VALUE pulse(VALUE rb_msg = Qnil)
            {
              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
          
              if ( $self->Pulse(new_msg) )
                return Qtrue;
              else
                return Qfalse;
            }
          
            VALUE pulse_and_check(VALUE rb_msg = Qnil)
            {
              VALUE ret = rb_ary_new();
          
              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
              
              bool skip = false;
              if ( $self->Pulse(new_msg, &skip) )
                rb_ary_push(ret, Qtrue);
              else 
                rb_ary_push(ret, Qfalse);
              
              rb_ary_push(ret, ( skip ? Qtrue : Qfalse) );
          
              return ret;
            }
          
            VALUE update(int value, VALUE rb_msg = Qnil)
            {
              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
          
              if ( $self->Update(value, new_msg) )
                return Qtrue;
              else
                return Qfalse;
            }
          
            VALUE update_and_check(int value, VALUE rb_msg = Qnil)
            {
              VALUE ret = rb_ary_new();
          
              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
          
              bool skip = false;
              if ( $self->Update(value, new_msg, &skip) )
                rb_ary_push(ret, Qtrue);
              else 
                rb_ary_push(ret, Qfalse);
          
              rb_ary_push(ret, ( skip ? Qtrue : Qfalse) );
          
              return ret;
            }
            __HEREDOC
        end
      end
    end # class Dialog

  end # class Director

end # module WXRuby3
