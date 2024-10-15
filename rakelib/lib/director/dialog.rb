# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
          spec.items << 'wxDialogLayoutAdapter'
          spec.gc_as_object 'wxDialogLayoutAdapter'
          spec.suppress_warning(514, 'wxDialogLayoutAdapter')
          spec.disown 'wxDialogLayoutAdapter* adapter'
          spec.new_object 'wxDialog::SetLayoutAdapter'
          spec.ignore('wxDialog::GetContentWindow',
                      'wxDialog::GetToolBar') # seemingly removed from MSW
          spec.swig_import('swig/classes/include/wxDefs.h')
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetDialogClass() {
              return SwigClassWxDialog.klass;
            }
          __HEREDOC
        when 'wxMessageDialog'
          spec.ignore 'wxMessageDialog::ButtonLabel'
          spec.map 'const ButtonLabel&' => 'String,Integer' do
            add_header_code 'typedef wxMessageDialog::ButtonLabel ButtonLabel;'
            map_in temp: 'std::unique_ptr<wxMessageDialog::ButtonLabel> tmp', code: <<~__CODE
              if (TYPE($input) == T_STRING)
              {
                tmp = std::make_unique<wxMessageDialog::ButtonLabel> (RSTR_TO_WXSTR($input));
              }
              else if (TYPE($input) == T_FIXNUM || wxRuby_IsAnEnum($input))
              {
                tmp = std::make_unique<wxMessageDialog::ButtonLabel> (NUM2INT($input));
              }
              else
              {
                rb_raise(rb_eArgError, "Expected string or stock id for %d", $argnum-1);
              }
              $1 = tmp.get();
              __CODE
            map_directorin code: <<~__CODE
              if ($1.GetStockId() != wxID_NONE)
              { $input = INT2NUM($1.GetStockId()); }
              else
              { $input = WXSTR_TO_RSTR($1.GetAsString()); }
              __CODE
          end
        when 'wxFontDialog'
          # ignore the non-const version
          if Config.platform == :macosx && Config.instance.wx_version < '3.3'
            # MacOSX implementation is incorrect so we need to use
            # the non-const definition here
            spec.ignore 'wxFontDialog::GetFontData() const'
          else
            spec.ignore 'wxFontDialog::GetFontData'
            spec.regard 'wxFontDialog::GetFontData() const'
          end
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
          # need to adjust sizer arg name to apply disown specs
          spec.ignore 'wxPropertySheetDialog::SetInnerSizer(wxSizer *)', ignore_doc: false
          spec.extend_interface 'wxPropertySheetDialog',
                                'void SetInnerSizer(wxSizer *sizer_disown)'
          spec.disown 'wxSizer *sizer_disown'
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
          # add undocumented method
          spec.extend_interface 'wxFindReplaceDialog', 'void SetData(wxFindReplaceData *data)'
          spec.do_not_generate(:variables, :enums)
        when 'wxColourDialog'
          spec.items << 'wxColourData'
          spec.gc_as_untracked 'wxColourData'
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
          spec.map 'void** clientData' do
            map_in ignore: true, code: '$1 = nullptr;'
          end
          spec.ignore 'wxSingleChoiceDialog::GetSelectionData'
          spec.do_not_generate(:functions)
        when 'wxMultiChoiceDialog'
          # unnneeded and unwanted for Ruby
          spec.ignore 'wxMultiChoiceDialog::wxMultiChoiceDialog(wxWindow *,const wxString &,const wxString &,int,const wxString *,long,const wxPoint &)'
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
        when 'wxCredentialEntryDialog'
          spec.items << 'wxWebCredentials'
          spec.do_not_generate(:functions, :enums, :defines)
        when 'wxGenericAboutDialog'
          # inheritance chain missing from wxw docs
          spec.override_inheritance_chain(spec.module_name, %w[wxDialog wxTopLevelWindow wxNonOwnedWindow wxWindow wxEvtHandler wxObject])
          spec.gc_as_dialog(spec.module_name)
          # regard protected methods
          spec.regard 'wxGenericAboutDialog::DoAddCustomControls',
                      'wxGenericAboutDialog::AddControl',
                      'wxGenericAboutDialog::AddText',
                      'wxGenericAboutDialog::GetCustomControlParent'
          if Config.instance.features_set?('USE_COLLPANE')
            spec.regard 'wxGenericAboutDialog::AddCollapsiblePane'
          end
        end
      end

      def process(gendoc: false)
        defmod = super
        spec.items.each do |citem|
          def_item = defmod.find_item(citem)
          if Extractor::ClassDef === def_item && (citem == 'wxDialog' || spec.is_derived_from?(def_item, 'wxDialog'))
            spec.no_proxy "#{spec.class_name(citem)}::ShowModal"
            spec.no_proxy "#{spec.class_name(citem)}::EndModal"
            spec.no_proxy "#{spec.class_name(citem)}::IsModal"
          end
        end
        defmod
      end

    end # class Dialog

  end # class Director

end # module WXRuby3
