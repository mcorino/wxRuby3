###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './top_level_window'

module WXRuby3

  class Director

    class Dialog < TopLevelWindow

      def setup
        super
        # overrule common typemap to allow default NULL
        spec.map 'wxWindow* parent' do
          map_check code: ''
        end
        case spec.module_name
        when 'wxDialog'
          spec.ignore('wxDialog::GetContentWindow',
                      'wxDialog::GetToolBar') # seemingly removed from MSW
          spec.swig_import('swig/classes/include/wxDefs.h')
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetDialogClass() {
              return SwigClassWxDialog.klass;
            }
          __HEREDOC
        when 'wxMessageDialog'
        when 'wxFontDialog'
          # ignore the non-const version
          spec.ignore 'wxFontDialog::GetFontData'
          spec.regard 'wxFontDialog::GetFontData() const'
        when 'wxFileDialog'
          # override the wxArrayString& typemap for GetFilenames and GetPaths
          spec.map 'wxArrayString&' => 'Array<String>' do
            map_in ignore: true, temp: 'wxArrayString sel', code: '$1 = &sel;'
            map_argout code: <<~__CODE
             $result = rb_ary_new();
             for (size_t i = 0; i < $1->GetCount(); i++)
               rb_ary_push($result, WXSTR_TO_RSTR( (*$1)[i] ) );
             __CODE
          end
          spec.ignore 'wxFileDialog::SetExtraControlCreator'
          if Config.instance.wx_version >= '3.2.1'
            # doc does not seem to match actual header code so just ignore for now
            spec.ignore('wxFileDialog::AddShortcut')
          end
          spec.do_not_generate :functions
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
          spec.map_apply 'SWIGTYPE *DISOWN' => 'wxFindReplaceData* data'
          spec.do_not_generate(:variables, :enums)
        when 'wxColourDialog'
          # make interface GC-safe
          spec.ignore 'wxColourDialog::GetColourData'
          spec.add_extend_code 'wxColourDialog', <<~__HEREDOC
            wxColourData* GetColourData()
            {
              return new wxColourData(self->GetColourData());
            }
            void SetColourData(const wxColourData& cd)
            {
              self->GetColourData() = cd;
            }
            __HEREDOC
          spec.new_object 'wxColourDialog::GetColourData'
        when 'wxTextEntryDialog'
          spec.items << 'wxPasswordEntryDialog'
        when 'wxSingleChoiceDialog'
          # unnneeded and unwanted for Ruby
          spec.ignore 'wxSingleChoiceDialog::wxSingleChoiceDialog(wxWindow *,const wxString &,const wxString &,int,const wxString *,void **,long,const wxPoint &)'
          # Wx's SingleChoiceDialog offers the possibility of attaching client
          # data to each choice. However this would need memory management, and a
          # pure ruby implementation is trivial and likely to be more convenient
          # on a per-case basis so just ignore this argument for Ruby.
          spec.map 'char** clientData' do
            map_in ignore: true, code: '$1 = (char **)NULL;'
          end
          spec.ignore 'wxSingleChoiceDialog::GetSelectionData'
          spec.do_not_generate(:functions)
        when 'wxMultiChoiceDialog'
          # unnneeded and unwanted for Ruby
          spec.ignore 'wxMultiChoiceDialog::wxMultiChoiceDialog(wxWindow *,const wxString &,const wxString &,int,const wxString *,long,const wxPoint &)'
          # Wx's MultiChoiceDialog offers the possibility of attaching client
          # data to each choice. However this would need memory management, and a
          # pure ruby implementation is trivial and likely to be more convenient
          # on a per-case basis so just ignore this argument for Ruby.
          spec.map 'char** clientData' do
            map_in ignore: true, code: '$1 = (char **)NULL;'
          end
          spec.do_not_generate(:functions, :enums, :defines)
        when 'wxDirDialog'
        when 'wxProgressDialog'
          spec.make_concrete 'wxProgressDialog'
          spec.items << 'wxGenericProgressDialog'
          spec.fold_bases('wxProgressDialog' => 'wxGenericProgressDialog')
          if Config.instance.windows?
            # The native dialog implementation for WXMSW is not usable with wxRuby because
            # of it's multi-threaded nature so we explicitly use the generic implementation here
            # (on most or all other platforms that is implicitly so).
            spec.use_class_implementation 'wxProgressDialog', 'wxGenericProgressDialog'
          end
          # These two have problematic arguments; they accept a bool pointer
          # which will be set to true if "skip" was pressed since the last
          # update. Dealt with below.
          spec.ignore(%w[wxGenericProgressDialog::Pulse wxGenericProgressDialog::Update])
          spec.add_extend_code 'wxProgressDialog', <<~__HEREDOC
            // In wxRuby we change the return value for these methods to be either:
            // - false if canceled
            // - true if not canceled nor skipped
            // - :skipped if skipped
            VALUE pulse(VALUE rb_msg = Qnil)
            {
              static WxRuby_ID skipped_id("skipped"); 

              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
          
              bool skip = false;
              if ( $self->Pulse(new_msg, &skip) )
              {
                if (skip) return ID2SYM(skipped_id());
                else      return Qtrue;
              }
              else
                return Qfalse;
            }
          
            VALUE update(int value, VALUE rb_msg = Qnil)
            {
              static WxRuby_ID skipped_id("skipped");
 
              wxString new_msg;
              if ( rb_msg == Qnil )
                new_msg = wxEmptyString;
              else
                new_msg = wxString( StringValuePtr(rb_msg), wxConvUTF8 );
          
              bool skip = false;
              if ( $self->Update(value, new_msg, &skip) )
              {
                if (skip) return ID2SYM(skipped_id());
                else      return Qtrue;
              }
              else
                return Qfalse;
            }
            __HEREDOC
        when 'wxWizard'
          # special handling
          spec.ignore 'wxWizard::GetBitmap'
          # add custom Ruby version
          spec.add_extend_code 'wxWizard', <<~__HEREDOC
            wxBitmap GetBitmap() const
            {
              return $self->GetBitmap();
            }
            __HEREDOC
          # handled; can be suppressed
          spec.suppress_warning(473,
                                'wxWizard::GetCurrentPage',
                                'wxWizard::GetPageAreaSizer')
          spec.do_not_generate(:variables, :enums, :defines, :functions)
        end
      end
    end # class Dialog

  end # class Director

end # module WXRuby3
