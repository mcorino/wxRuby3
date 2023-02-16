###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './pgproperty'

module WXRuby3

  class Director

    class PGProperties < PGProperty

      include Typemap::DateTime

      def setup
        spec.items.replace %w[
          wxBoolProperty wxDateProperty wxFlagsProperty wxStringProperty wxPropertyCategory
          wxEditorDialogProperty wxArrayStringProperty wxDirProperty wxFileProperty
          wxImageFileProperty wxFontProperty wxLongStringProperty wxMultiChoiceProperty
          wxNumericProperty wxIntProperty wxFloatProperty wxUIntProperty
          wxEnumProperty wxCursorProperty wxEditEnumProperty wxSystemColourProperty wxColourProperty wxColourPropertyValue
          ]
        super
        spec.ignore 'wxEnumProperty::wxEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, int)',
                    'wxEnumProperty::wxEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, wxPGChoices *, int)'
        spec.ignore 'wxEditEnumProperty::wxEditEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, const wxString&)',
                    'wxEditEnumProperty::wxEditEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, wxPGChoices *, const wxString&)'
        spec.regard 'wxEnumProperty::GetIndex',
                    'wxEnumProperty::SetIndex',
                    'wxEnumProperty::ValueFromString_',
                    'wxEnumProperty::ValueFromInt_'
        spec.gc_as_temporary 'wxColourPropertyValue'
        spec.regard 'wxColourPropertyValue::m_type',
                    'wxColourPropertyValue::m_colour'
        spec.regard 'wxSystemColourProperty::Init',
                    'wxSystemColourProperty::DoTranslateVal',
                    'wxSystemColourProperty::ColToInd',
                    'wxColourProperty::DoTranslateVal'
        spec.rename_for_ruby 'type_'=> 'wxColourPropertyValue::m_type',
                             'colour_' => 'wxColourPropertyValue::m_colour'
        spec.regard 'wxNumericProperty::wxNumericProperty'
        spec.regard 'wxMultiChoiceProperty::GenerateValueAsString',
                    'wxMultiChoiceProperty::GetValueAsIndices'
        spec.regard 'wxNumericProperty::m_minVal',
                    'wxNumericProperty::m_maxVal',
                    'wxNumericProperty::m_spinMotion',
                    'wxNumericProperty::m_spinStep',
                    'wxNumericProperty::m_spinWrap',
                    'wxEditorDialogProperty::m_dlgTitle',
                    'wxEditorDialogProperty::m_dlgStyle',
                    'wxEnumProperty::GetIndex',
                    'wxEnumProperty::SetIndex',
                    'wxEnumProperty::ValueFromString_',
                    'wxEnumProperty::ValueFromInt_',
                    'wxFileProperty::m_wildcard',
                    'wxFileProperty::m_basePath',
                    'wxFileProperty::m_initialPath',
                    'wxFileProperty::m_indFilter',
                    'wxArrayStringProperty::m_display',
                    'wxArrayStringProperty::m_delimiter',
                    'wxArrayStringProperty::m_customBtnText',
                    'wxMultiChoiceProperty::m_display',
                    'wxMultiChoiceProperty::m_userStringMode',
                    'wxFloatProperty::m_precision',
                    'wxUIntProperty::m_base',
                    'wxUIntProperty::m_realBase',
                    'wxUIntProperty::m_prefix',
                    'wxDateProperty::m_format',
                    'wxDateProperty::m_dpStyle'
        spec.rename_for_ruby 'min_val_' => 'wxNumericProperty::m_minVal',
                             'max_val_' => 'wxNumericProperty::m_maxVal',
                             'spin_motion_' => 'wxNumericProperty::m_spinMotion',
                             'spin_step_' => 'wxNumericProperty::m_spinStep',
                             'spin_wrap_' => 'wxNumericProperty::m_spinWrap',
                             'dlg_title_' => 'wxEditorDialogProperty::m_dlgTitle',
                             'dlg_style_' => 'wxEditorDialogProperty::m_dlgStyle',
                             'display_' => %w[wxArrayStringProperty::m_display wxMultiChoiceProperty::m_display],
                             'delimiter_' => 'wxArrayStringProperty::m_delimiter',
                             'custom_btn_text_' => 'wxArrayStringProperty::m_customBtnText',
                             'user_string_mode_' => 'wxMultiChoiceProperty::m_userStringMode',
                             'precision_' => 'wxFloatProperty::m_precision',
                             'base_' => 'wxUIntProperty::m_base',
                             'real_base_' => 'wxUIntProperty::m_realBase',
                             'prefix_' => 'wxUIntProperty::m_prefix',
                             'format_' => 'wxDateProperty::m_format',
                             'dp_style_' => 'wxDateProperty::m_dpStyle'
        # make sure the derived Numeric property classes provide the protected accessors too
        %w[wxIntProperty wxFloatProperty wxUIntProperty].each do |kls|
          spec.extend_interface kls,
                                'wxVariant m_minVal',
                                'wxVariant m_maxVal',
                                'bool m_spinMotion',
                                'wxVariant m_spinStep',
                                'bool m_spinWrap',
                                visibility: 'protected'
          spec.rename_for_ruby 'min_val_' => "#{kls}::m_minVal",
                               'max_val_' => "#{kls}::m_maxVal",
                               'spin_motion_' => "#{kls}::m_spinMotion",
                               'spin_step_' => "#{kls}::m_spinStep",
                               'spin_wrap_' => "#{kls}::m_spinWrap"
        end
        # make sure the derived Enum property classes provide the protected accessors too
        %w[wxCursorProperty wxEditEnumProperty wxSystemColourProperty wxColourProperty].each do |kls|
          spec.extend_interface kls,
                                'int GetIndex() const',
                                'void SetIndex(int index)',
                                'bool ValueFromString_ (wxVariant &value, const wxString &text, int argFlags) const',
                                'bool ValueFromInt_ (wxVariant &value, int intVal, int argFlags) const',
                                visibility: 'protected'
        end
        spec.regard 'wxEditorDialogProperty::wxEditorDialogProperty',
                    'wxEditorDialogProperty::DisplayEditorDialog',
                    'wxArrayStringProperty::DisplayEditorDialog',
                    'wxDirProperty::DisplayEditorDialog',
                    'wxFileProperty::DisplayEditorDialog',
                    'wxLongStringProperty::DisplayEditorDialog',
                    'wxMultiChoiceProperty::DisplayEditorDialog',
                    'wxFontProperty::DisplayEditorDialog'
        spec.new_object 'wxArrayStringProperty::CreateEditorDialog'
        spec.suppress_warning(473, 'wxArrayStringProperty::CreateEditorDialog')
        # for wxArrayStringProperty::OnCustomStringEdit
        spec.map 'wxWindow *parent, wxString &value' do
          map_in from: {type: 'Wx::Window', index: 0},
                 temp: 'wxString tmp',
                 code: <<~__CODE
            void* argp$argnum = NULL;
            if ( TYPE($input) == T_DATA )
            {
              if (SWIG_IsOK(SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, $argnum-1)) && argp$argnum)
              {
                $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
              }
              else
              {
                rb_raise(rb_eTypeError, "Expected Wx::Window instance.");
              }
            }
            $2 = &tmp;
            __CODE
          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'
          map_argout as: {type: 'String', index: 1}, code: '$result = WXSTR_TO_RSTR(tmp$argnum);'
          # convert the window and ignore the string ref for now
          map_directorin code: '$input = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxWindow, 0);'
          map_directorargout code: <<~__CODE
            if (RTEST($result))
            {
              if (TYPE($result) == T_STRING)
              {
                value = RSTR_TO_WXSTR($result);
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(rb_eTypeError, 
                                                           "on_custom_string_edit should return a string, or nil");
              }
            }
            else
              c_result = false;
          __CODE
        end
        # not needed in wxRuby
        spec.ignore 'wxFlagsProperty::wxFlagsProperty(const wxString &, const wxString &, const wxChar *const *, const long *, long)'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end
    end # class PGProperties

  end # class Director

end # module WXRuby3
